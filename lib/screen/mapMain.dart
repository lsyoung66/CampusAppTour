import 'dart:async';
import 'dart:convert';
import 'package:campus_app_tour/screen/object_detect.dart';
import 'package:campus_app_tour/screen/review.dart';
import 'package:campus_app_tour/screen/reviews.dart';
import 'package:campus_app_tour/screen/spot_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campus_app_tour/screen/my_page.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:location/location.dart' as loc;
// ignore: depend_on_referenced_packages
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:campus_app_tour/main_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../kakao_social_login_IMPL.dart';
import 'home.dart';

// import ‘package:get/get.dart’;
bool isOrienteeringInProgress =
    false; // Flag to track if orienteering is in progress

class MapMain extends StatefulWidget {

  final bool isFloatingActionButtonVisible;	
  final Function toggleFloatingActionButton;	
  MapMain({	
    required this.isFloatingActionButtonVisible,	
    required this.toggleFloatingActionButton,	
  });
  @override
  State<MapMain> createState() => MapMainState();
}

class MapMainState extends State<MapMain> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );
  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  String serverIdAddress = "172.30.1.43";
  Completer<GoogleMapController> _controller = Completer();
  List<Marker> _markers = [];
  late BitmapDescriptor customIconA;
  late BitmapDescriptor customIconB;
  late BitmapDescriptor customIconC;
  late BitmapDescriptor spotIcon;

  String currentCourseName = '';
  String selectCourseName = '';
  List<String> currentSpotList = [];
  bool isOrienteeringFinished = false;
  bool isCourseMarkerSelected = false;
  bool isShowSpots = false;
  List<String> spotTitles = [];
  double changeheight = 70;
  loc.LocationData? currentLocation;
  List<Widget> spotContainers = [];

  // 초기 카메라 위치
  static final CameraPosition _dcu = CameraPosition(
    target: LatLng(35.911853535776025, 128.8086126724661),
    zoom: 15.8746,
  );

  @override
  void initState() {
    super.initState();
    // final viewModel = MainViewModel(KakaoSocialLogin());
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    // var userProgress = await viewModel.getMyProgress(userKakaoId);
    // if (userProgress[0] == {}) {
    //   isOrienteeringInProgress = false;
    // }
    _addMarkers(); // 코스 및 스팟 마커 생성
    requestLocationPermission();
    getLocation();
    getUserCourse();
    getCurrentLocation();
  }

  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  void _removeOtherMarkers(MarkerId markerId) {
    _onMarkerTapped(markerId);
    Navigator.of(context).pop();
  }

  void getUserCourse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    var data = await viewModel.getMyProgress(userKakaoId);
    print("+++++++++++++++++++++++");
    print(data);
    String userCourse = data[0]['progress']['course_name'];
    print("+++++++++++++++++++++++");
    print(userCourse);
    if (userCourse != null && userCourse.isNotEmpty) {
      var usercoursename = 'course' + userCourse;
      _removeOtherMarkers(MarkerId(usercoursename));
      if (!userCourse.isEmpty) {
        setState(() {
          selectCourseName = userCourse + '코스';
          isOrienteeringInProgress = true;
        });
      } else {
        isOrienteeringInProgress = false;
      }
    }
  }

  Future<void> getLocation() async {
    final location = loc.Location();
    final hasPermission = await location.hasPermission();
    if (hasPermission == PermissionStatus.granted) {
      final locationData = await location.getLocation();
      setState(() {
        currentLocation = locationData;
      });
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted, initialize the map
      setState(() {});
    } else {
      // Permission denied, handle accordingly
      // For example, you can show a dialog or display a message to the user
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('위치 동의 확인'),
          content: Text('앱을 이용하시려면 위치 동의가 필요합니다. 동의하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('동의'),
              onPressed: () {
                Navigator.pop(context);
                AppSettings.openAppSettings(); // 앱 설정 화면으로 이동
              },
            ),
          ],
        ),
      );
    }
  }
    bool isCompleted = true;

  void _addMarkers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    var completedCourses = await viewModel.getMyCompletedCourse(userKakaoId);
    print("!!!!!!!!!!!!!!");
    print(completedCourses);

    for (var data in completedCourses) {
      print("@@@@@@@@");
      print(data['course_name'].toString());
      if (data['course_name'].toString() == "A") {
      setState(() {
        isCompleted = true;
      });}
      // isCompleted = true;
      print("111111111111");
      print(isCompleted);
    }
    // if (isCompleted) {
    //   customIconA = await BitmapDescriptor.fromAssetImage(
    //       ImageConfiguration(devicePixelRatio: 2.5),
    //       'assets/images/completedIconA.png');
    // } else {
    //   customIconA = await BitmapDescriptor.fromAssetImage(
    //       ImageConfiguration(devicePixelRatio: 2.5),
    //       'assets/images/courseA.png');
    // }

    String getIconImagePath() {
      return iscompleted
          ? 'assets/images/completedIconA.png'
          : 'assets/images/courseA.png';
    }

    print(getIconImagePath());

    // 'A코스' 마커 이미지 생성
    customIconA = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), getIconImagePath(),
            );

    isCompleted = false;

    for (var data in completedCourses) {
      if (data['course_name'].toString() == "B") isCompleted = true;
      print("2222222222");
      print(isCompleted);
    }

    // 'B코스' 마커 이미지 생성
    customIconB = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        iscompleted
            ? 'assets/images/completedIconB.png'
            : 'assets/images/courseB.png');
    isCompleted = false;

    for (var data in completedCourses) {
      if (data['course_name'].toString() == "C") isCompleted = true;
      print("3333333");
      print(isCompleted);
    }
    // 'C코스' 마커 이미지 생성
    customIconC = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        iscompleted
            ? 'assets/images/completedIconC.png'
            : 'assets/images/courseC.png');
    // 스팟 이미지 생성
    spotIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/spotIcon.png',
    );
    _addAdditionalMarkers(
        'A코스'); // Assuming you have the 'spotIcon' defined somewhere

    setState(() {}); // 마커를 추가한 후에는 setState()를 호출하여 변경 사항을 반영
  }

  Future<void> _addAdditionalMarkers(String course) async {
    _markers.clear();
    //final List<String> spots = await fetchSpots(course); // spot 목록 가져오기

    // 코스 마커 추가
    _markers.addAll([
      // 각 코스 마커 추가
      Marker(
        markerId: MarkerId('courseA'),
        position: LatLng(35.910079289728856, 128.80690524526528),
        icon: customIconA,
        onTap: () {
          if (!isOrienteeringInProgress) {
            _addAdditionalMarkers('A코스'); // 마커 표시
            _onMarkerTapped(MarkerId('courseA')); // 마커 선택시 스팟&모달창 출력
          }
        },
      ),
      Marker(
        markerId: MarkerId('courseB'),
        position: LatLng(35.910568044674626, 128.81064921211248),
        icon: customIconB,
        onTap: () {
          if (!isOrienteeringInProgress) {
            _addAdditionalMarkers('B코스'); // 마커 표시
            _onMarkerTapped(MarkerId('courseB')); // 마커 선택시 스팟&모달창 출력
          }
        },
      ),
      Marker(
        markerId: MarkerId('courseC'),
        position: LatLng(35.91312916427164, 128.80812663220968),
        icon: customIconC,
        onTap: () {
          if (!isOrienteeringInProgress) {
            _addAdditionalMarkers('C코스'); // 마커 표시
            _onMarkerTapped(MarkerId('courseC')); // 마커 선택시 스팟&모달창 출력
          }
        },
      ),
    ]);
    setState(() {});
  }

  void _showCourseModal(
      //코스 선택시 출력되는 모달창
      BuildContext context,
      String courseName,
      List<String> spotTitles) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$courseName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 8.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: spotTitles.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(spotTitles[index]),
                  );
                },
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      isOrienteeringInProgress
                          ? _finishOrienteering()
                          : _startOrienteering(
                              courseName, spotTitles); // Start orienteering
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                    ),
                    child: Text(
                      isOrienteeringInProgress ? 'DROPOUT' : 'START',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewPage(
                            courseName: courseName,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    child: Text('REVIEW'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _startOrienteering(String courseName, List<String> spotTitles) async {
    final viewModel = MainViewModel(KakaoSocialLogin());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    String accessToken = prefs.getString('access_token') ?? "";
    loggerNoStack.w(userKakaoId, accessToken);

    bool isSuccessful =
        await viewModel.startCourse(userKakaoId, accessToken, courseName);
    if (isSuccessful) {
      setState(() {
        isOrienteeringInProgress = true;
        selectCourseName = courseName;
        print(currentCourseName);
        currentSpotList = spotTitles;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text("!!"),
            content: Text("현재 진행중인 코스가 있습니다."),
            actions: [
              TextButton(
                child: Text("확인"),
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
            ],
          );
        },
      );
    }

    // _onMarkerTapped(MarkerId(spotTitles[0]));
  }

  void _finishOrienteering() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    String userAccessToken = prefs.getString('access_token') ?? "";

    bool isSuccessful =
        await viewModel.dropOutCourse(userKakaoId, userAccessToken);
    if (isSuccessful) {
      setState(() {
        isOrienteeringInProgress = false;
        isOrienteeringFinished = true;
        isShowSpots = false;
        _showAllCourseMarkers();
      });
    }
  }

  void _addMarker(
      LatLng position, String id, String title, BitmapDescriptor spotIcon) {
    final markerId = MarkerId(id);
    final marker = Marker(
      markerId: markerId,
      position: position,
      onTap: () => _onMarkerTapped(id as MarkerId), // 코스 마커 선택 시 스팟 마커들 출력
      infoWindow: InfoWindow(title: title),
      icon: spotIcon,
    );
    setState(() {
      _markers.add(marker);
    });
  }

  void _onMarkerTapped(MarkerId markerId) async {
    String courseName = '';
    List<String> spotTitles = [];
    _markers.removeWhere((marker) => marker.markerId.value != markerId.value);
    if (markerId.value == 'courseA') {
      courseName = 'A코스';
      spotTitles = ['성모상', '대가대조형물', '김종복미술관', '기숙사분수대'];
      _addMarker(LatLng(35.9105, 128.8081), 'am1', spotTitles[0], spotIcon);
      _addMarker(LatLng(35.9103, 128.8083), 'am2', spotTitles[1], spotIcon);
      _addMarker(LatLng(35.909, 128.8075), 'am3', spotTitles[2], spotIcon);
      _addMarker(LatLng(35.9105, 128.8053), 'am4', spotTitles[3], spotIcon);
    } else if (markerId.value == 'courseB') {
      courseName = 'B코스';
      spotTitles = ['100주년 기념광장', '잔디광장', '전석재 몬시뇰 동상', '박물관', '희망의 예수상'];
      _addMarker(LatLng(35.9108, 128.8101), 'bm1', spotTitles[0], spotIcon);
      _addMarker(LatLng(35.9122, 128.8099), 'bm2', spotTitles[1], spotIcon);
      _addMarker(LatLng(35.9105, 128.8114), 'bm3', spotTitles[2], spotIcon);
      _addMarker(LatLng(35.9102, 128.8115), 'bm4', spotTitles[3], spotIcon);
      _addMarker(LatLng(35.9095, 128.8098), 'bm5', spotTitles[4], spotIcon);
    } else if (markerId.value == 'courseC') {
      courseName = 'C코스';
      spotTitles = ['치유광장', '체리로드', '은행나무길', '스트로마톨라이트', '안중근 의사 동상'];
      _addMarker(LatLng(35.9115, 128.8089), 'cm1', spotTitles[0], spotIcon);
      _addMarker(LatLng(35.912, 128.8089), 'cm2', spotTitles[1], spotIcon);
      _addMarker(LatLng(35.9138, 128.8084), 'cm3', spotTitles[2], spotIcon);
      _addMarker(LatLng(35.9148, 128.8083), 'cm4', spotTitles[3], spotIcon);
      _addMarker(LatLng(35.9126, 128.8066), 'cm5', spotTitles[4], spotIcon);
    }

    final name = courseName.substring(0, 1);

    Future<List<String>> fetchSpots(String name) async {
      final response = await http.get(
          Uri.parse("http://" + serverIdAddress + ":3000/course/$name/spots"));
      if (response.statusCode == 200) {
        final List<dynamic> spotsJson = jsonDecode(response.body);
        return List<String>.from(spotsJson);
      } else {
        throw Exception('Failed to load spots');
      }
    }

    setState(() {
      currentCourseName = markerId.value;
      currentSpotList = spotTitles;
      isCourseMarkerSelected = true;
    });
    _showCourseModal(context, courseName, spotTitles);
  }

  void _showAllCourseMarkers() {
    // 지도 위 마커 초기화
    _markers.clear();

    // 다시 모든 코스 마커 출력하기
    _markers.addAll([
      Marker(
        markerId: MarkerId('courseA'),
        position: LatLng(35.910079289728856, 128.80690524526528),
        icon: customIconA,
        onTap: () {
          if (!isOrienteeringInProgress) {
            _onMarkerTapped(MarkerId('courseA'));
          }
        },
      ),
      Marker(
        markerId: MarkerId('courseB'),
        position: LatLng(35.910568044674626, 128.81064921211248),
        icon: customIconB,
        onTap: () {
          if (!isOrienteeringInProgress) {
            _onMarkerTapped(MarkerId('courseB'));
          }
        },
      ),
      Marker(
        markerId: MarkerId('courseC'),
        position: LatLng(35.91312916427164, 128.80812663220968),
        icon: customIconC,
        onTap: () {
          if (!isOrienteeringInProgress) {
            _onMarkerTapped(MarkerId('courseC'));
          }
        },
      ),
    ]);
    setState(() {});
  }

  final viewModel = MainViewModel(KakaoSocialLogin());

  void _fetchSpotListFromServer(MarkerId markerId) async {
    List<String> spotTitles = [];
    changeheight = 890;
    spotContainers = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    String accessToken = prefs.getString('access_token') ?? "";
    var spotProgress = await viewModel.getMyProgress(userKakaoId);
    var spotsInCourse = spotProgress[1]['spots_in_course'];
    var completedSpot = spotProgress[2]['spots_completed'];

    if (markerId.value == 'courseA') {
      selectCourseName = 'A코스';
    } else if (markerId.value == 'courseB') {
      selectCourseName = 'B코스';
    } else if (markerId.value == 'courseC') {
      selectCourseName = 'C코스';
    }

    iscompleted = false;
    var progress = await viewModel.getMyProgress(userKakaoId);
    var userProgress = progress[0]['progress'];
    print(userProgress);
    if (userProgress['spots_in_course'].toString() ==
        userProgress['spots_completed'].toString()) {
      print('=========course completed ===========');
      iscompleted = true;
    } else {
      print("spot not completed");
    }

    setState(() {
      currentCourseName = markerId.value;
      currentSpotList = []; // 스팟 목록 초기화
      isShowSpots = !isShowSpots;
      print(isShowSpots);
    });
    buildSpotContainers(spotsInCourse, completedSpot, userKakaoId, accessToken);
  }

  bool iscompleted = false;
  void _closeSpotsList() async {
    setState(() {
      isShowSpots = !isShowSpots;
      changeheight = 70;
      //updateCourseCompleted();
    });
  }

  void buildSpotContainers(
    var spotsInCourse,
    var completedSpot,
    var userKakaoId,
    var accessToken,
  ) {
    bool isVerified = false;

    print(completedSpot);
    for (var _spot in spotsInCourse) {
      isVerified = false;
      for (var spot in completedSpot) {
        if (spot['spot_name'] == _spot['spot_name']) {
          isVerified = true;
        }
      }

      var spotIdx = _spot['idx'];

      spotContainers.add(
        Container(
          padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SpotDetailPage(spotName: _spot['spot_name']),
                      ),
                    );
                  },
                  child: Text(
                    _spot['spot_name'],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GestureDetector(
                onTap: isVerified
                    ? null // isVerified가 true일 때는 터치 이벤트 무시
                    : () async {
                        bool state = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyObjectDetect(data: _spot['spot_name']),
                          ),
                        );
                        if (true) {
                          setState(() async {
                            await viewModel.spotComplete(
                                userKakaoId, accessToken, spotIdx.toString());
                            _closeSpotsList();
                            _fetchSpotListFromServer(
                                MarkerId(currentCourseName));
                          });
                        }
                      },
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: isVerified ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isVerified ? Icons.check : Icons.camera_alt,
                      color: Colors.white,
                      size: isVerified ? 25 : 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  IconButton buildIconButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          isShowSpots = !isShowSpots; // isShowSpots 상태 변경
          print(isShowSpots);
        });
      },
      icon: Icon(
        isShowSpots ? Icons.cancel_rounded : Icons.arrow_forward_ios_rounded,
        color: isShowSpots ? Color(0xFFFF6F00) : Colors.black,
        size: 35,
      ),
    );
  }

// final name = selectCourseName.substring(0, 1);

  // if (name.isNotEmpty) {
  //   final url =
  //       Uri.parse("http://" + serverIdAddress + ":3000/course/$name/spots");
  //   final response = await http.get(url);

  //   print('Request URL: $url'); // 요청하는 URL 콘솔에 출력

  //   print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     final spots = json.decode(response.body);
  //     spotTitles = List<String>.from(spots);
  //     print('Received spots: $spotTitles'); // 받은 값 콘솔에 출력
  //   } else {
  //     throw Exception('Failed to load spots');
  //   }
  // }

  Future<void> updateCourseCompleted() async {
    try {
      final response = await http.get(
          Uri.parse('http://' + serverIdAddress + ':3000/courseCompleted'));
      if (response.statusCode == 200) {
        print('Course completion updated successfully');
        final isCompletedValues = json.decode(response.body);
        print('dffwefwefwe');
        print(isCompletedValues[0]);
        if (isCompletedValues[0] == 1) {
          print('eee');
          setState(() {
            iscompleted = true;
          });
        }
      } else {
        print('ddfefffwewe');
        print(response.statusCode);
      }
    } catch (error) {
      print('An error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: _dcu,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              getLocation();
            },
            markers: Set<Marker>.from(_markers),
            onTap: (_) {
              // 이미 코스가 선택되어 있는 상태? 아무 곳이나 탭하면 다시 모든 코스 출력하도록 작성
              if (isCourseMarkerSelected && !isOrienteeringInProgress) {
                isCourseMarkerSelected = false;
                _showAllCourseMarkers();
              }
            },
          ),
          if (widget.isFloatingActionButtonVisible)
            Align(
              alignment: Alignment(
                  Alignment.bottomLeft.x + 1.95, Alignment.bottomLeft.y - 0.23),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Mypage()));
                },
                child: Icon(Icons.person),
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
              )),
          if (widget.isFloatingActionButtonVisible)
          Align(
              alignment: Alignment(
                  Alignment.bottomLeft.x + 1.51, Alignment.bottomLeft.y - 0.22),
                  
              child: FloatingActionButton(
                onPressed: () {
                  if (!isOrienteeringInProgress) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '코스를 선택해주세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.white,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (!isOrienteeringFinished) {
                    _showCourseModal(
                        context, currentCourseName, currentSpotList);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text('오리엔티어링을 종료하시겠습니까?'),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                _finishOrienteering(); // Finish orienteering
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                              ),
                              child: Text('종료'),
                            ),
                            TextButton(
                              child: Text('취소'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Icon(
                  isOrienteeringFinished ? Icons.check : Icons.flag,
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
              )),
          if (widget.isFloatingActionButtonVisible)
          Align(
              alignment: Alignment(
                  Alignment.bottomLeft.x + 1.25, Alignment.bottomLeft.y - 0.05),
              child: FloatingActionButton(
                onPressed: () {
                  _goToAllCourse();
                },
                child: Icon(Icons.map),
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
              )),
          Align(
              alignment: Alignment(
                  Alignment.bottomLeft.x + 0.06, Alignment.bottomLeft.y - 0.05),
              child: FloatingActionButton(
                onPressed: () {
                  setInitialCameraPosition();
                },
                child: Icon(Icons.my_location_rounded),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              )),
          Align(
            alignment: Alignment(
                Alignment.bottomRight.x, Alignment.bottomLeft.y - 0.03),
            child: Container(
              width: 150,
              height: 60,
              child: Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 80,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFAC00).withOpacity(0.45),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: MediaQuery.of(context).size.width * 0.9,
                    // height:changeheight,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Stack(
                        children: [
                          isOrienteeringInProgress
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 15),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            selectCourseName,
                                            style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: Color(0XFFFF6F00),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '진행중',
                                              style: TextStyle(
                                                fontSize: 23,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 2),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            onPressed: () {
                                              print(isShowSpots);
                                              isShowSpots
                                                  ? _closeSpotsList()
                                                  : _fetchSpotListFromServer(
                                                      MarkerId(
                                                          currentCourseName));
                                            },
                                            icon: buildIconButton().icon,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                height: 50,
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        '코스를 선택해주세요',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ),
                          isShowSpots
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 55, bottom: 25),
                                      child: Column(
                                        children: spotContainers,
                                      ),
                                    ),
                                    iscompleted
                                        ? Reviews(callback: _closeSpotsList)
                                        : Container(),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _goToAllCourse() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(35.911642390742266, 128.80857186553993),
      zoom: 15.8746,
    )));
  }

  Future<void> setInitialCameraPosition() async {
    var gps = await getCurrentLocation();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(gps.latitude, gps.longitude), zoom: 15.8746)));
  }
}
