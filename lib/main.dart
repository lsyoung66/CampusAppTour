import 'dart:async';

import 'package:campus_app_tour/kakao_social_login_IMPL.dart';
import 'package:campus_app_tour/main_view_model.dart';
import 'package:campus_app_tour/screen/home.dart';
import 'package:campus_app_tour/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '80ea3338e9a04d2545af91f8a36730f4',
    javaScriptAppKey: '17db58e5b289f6bbf482f43c0fd7c0d1',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus App Tour',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 250),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final String imageLogoName = 'assets/images/splash.png';

    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 142, 55),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.384375),
            Container(
              child: Image.asset(
                imageLogoName,
                width: screenWidth * 0.8,
                height: screenHeight * 0.2,
              ),
            ),
            Expanded(child: SizedBox()),
            Align(
              child: Text(
                "© Copyright 2023, CAT(Campus App tour)",
                style: TextStyle(
                  fontSize: screenWidth * (14 / 360),
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.0625),
          ],
        ),
      ),
    );
  }
}