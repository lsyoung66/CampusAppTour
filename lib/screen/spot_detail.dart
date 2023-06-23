import 'package:campus_app_tour/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:campus_app_tour/screen/object_detect.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campus_app_tour/main_view_model.dart';
import 'package:campus_app_tour/kakao_social_login_IMPL.dart';

class SpotDetailPage extends StatefulWidget {
  final String spotName;

  SpotDetailPage({required this.spotName});

  @override
  _SpotDetailPageState createState() => _SpotDetailPageState();
}

class _SpotDetailPageState extends State<SpotDetailPage> {
  final viewModel = MainViewModel(KakaoSocialLogin());
  String _spotName = "";
  String spotDescription = "";
  String spotImage = "";

  @override
  void initState() {
    super.initState();
    setSpotData(widget.spotName);
  }

  Future<void> setSpotData(String spotName) async {
    var spotInfo = await viewModel.getSpotInfo(spotName);
    setState(() {
      spotDescription = spotInfo['spot_description'];
      spotImage = spotInfo['spot_image'];
      _spotName = spotInfo['spot_name'];
      print("!!!!");
      print(spotName);
    });
    print(spotInfo);
  }

  @override
  Widget build(BuildContext context) {
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              _spotName,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: spotImage.isNotEmpty
                  ? Image.network(
                      "http://172.30.1.43:3000" + spotImage,
                      // "http://10.32.1.171:3000/images/dcu.jpg",
                      fit: BoxFit.cover,
                    )
                  : Container(), // 이미지가 로드되지 않았을 때 표시할 기본 컨테이너
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              spotDescription,
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
