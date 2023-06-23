import 'dart:io';
import 'package:campus_app_tour/screen/mapMain.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import 'home.dart';

/*class ObjectDetect extends StatelessWidget {
  final String data;
  const ObjectDetect({required this.data,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyObjectDetect(),
    );
  }
}*/

class MyObjectDetect extends StatefulWidget {
  final String data;
  const MyObjectDetect({required this.data, Key? key}) : super(key: key);

  @override
  State<MyObjectDetect> createState() => _MyObjectDetectState();
}

class _MyObjectDetectState extends State<MyObjectDetect> {
  CameraImage? img;
  dynamic controller;
  dynamic objectDetector;
  bool isBusy = false;
  dynamic _detectedObjects;
  List<Widget> stackChildren = [];
  late String? labelString = null;
  late String confidenceString = '80';
  late int count = 1;

  @override
  void initState() {
    super.initState();
    initModel();
    initCamera();
  }

  initModel() async {
    final modelPath = await _getModel('assets/model/classifier.tflite');

    final options = LocalObjectDetectorOptions(
      modelPath: modelPath,
      classifyObjects: true, //객체 감지 활성화
      multipleObjects: false, // 다중 객체 감지 여부
      mode: DetectionMode.single, // single 단일 이미지 ,stream 영상 이미지
      confidenceThreshold: 0.75, // 정확도 임계치
    );
    objectDetector = ObjectDetector(options: options);
  }

  initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize().then((_) async {
      await startStream();
      if (!mounted) {
        return;
      }
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('Camera access denied!');
            break;
          default:
            print('Camera initialization error!');
            break;
        }
      }
    });
  }

  Future<String> _getModel(String assetPath) async {
    if (Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
    }
    return file.path;
  }

  startStream() async {
    await controller.startImageStream((image) async {
      if (!isBusy) {
        isBusy = true;
        img = image;
        await performDetectionOnFrame();
      }
    });
  }

  performDetectionOnFrame() async {
    final frameImg = getInputImage();
    final objects = await objectDetector.processImage(frameImg);
    double zoomLevel = await controller.getMaxZoomLevel();
    setState(() {
      _detectedObjects = objects;
    });
    isBusy = false;
  }

  InputImage getInputImage() {
    final allBytes = WriteBuffer();
    for (final Plane plane in img!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final imageSize = Size(img!.width.toDouble(), img!.height.toDouble());

    final planeData = img!.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();
    InputImageRotation imageRotation = InputImageRotation.rotation0deg;

    final inputImageData = InputImageData(
      size: imageSize,
      inputImageFormat: InputImageFormatValue.fromRawValue(
        img!.format.raw,
      )!,
      planeData: planeData,
      imageRotation: imageRotation,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      inputImageData: inputImageData,
    );

    return inputImage;
  }

  Widget drawRectangleOverObjects() {
    if (_detectedObjects == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Loading...'),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    final imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    final painter = ObjectPainter(imageSize, _detectedObjects, this);
    return CustomPaint(
      painter: painter,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (controller != null) {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child: (controller.value.isInitialized)
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  )
                : Container(),
          ),
        ),
      );
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: drawRectangleOverObjects(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          FourDotsIcon(
            size: 30,
            color: Colors.black,
            onPressed: () {},
          )
        ],
        title: Center(
          child: Image.asset(
            'assets/images/logo2.png',
            width: 150,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 0),
              color: Colors.black,
              child: Stack(
                children: stackChildren,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
  widget.data.toLowerCase(),
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.red,
  ),
),
SizedBox(height: 10,),
                if ((labelString == widget.data) &&
                    (double.parse(confidenceString) >= 0.75)) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white, // 버튼 배경색을 흰색으로 설정
                      primary:
                          Color(0XFFFF6F00), // 버튼 글자 색을 Color(0XFFFF6F00)로 설정
                    ),
                    child: Text('메인화면으로 돌아가기'),
                  )
                ],
                // onChanged: [(labelString) {
                //     if((labelString==widget.data)&&(double.parse(confidenceString)>=0.75)){
                //       Navigator.pop(context, true
                //     );
                //     }
                //   },],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ObjectPainter extends CustomPainter {
  final _MyObjectDetectState parentState;

  ObjectPainter(this.imgSize, this.objects, this.parentState);

  final Size imgSize;
  final List<DetectedObject> objects;
  bool spot_val = true;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / imgSize.width;
    final double scaleY = size.height / imgSize.height;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = const Color.fromARGB(137, 255, 39, 39);

    for (DetectedObject detectedObject in objects) {
      canvas.drawRect(
        Rect.fromLTRB(
          detectedObject.boundingBox.left * scaleX,
          detectedObject.boundingBox.top * scaleY,
          detectedObject.boundingBox.right * scaleX,
          detectedObject.boundingBox.bottom * scaleY,
        ),
        paint,
      );

      var list = detectedObject.labels;
      for (Label label in list) {
        parentState.labelString = label.text;
        parentState.confidenceString = label.confidence.toStringAsFixed(2);
        parentState.count++;

        print(parentState.count);
      }
    }
  }

  @override
  bool shouldRepaint(ObjectPainter oldDelegate) {
    return oldDelegate.imgSize != imgSize || oldDelegate.objects != objects;
  }
}
