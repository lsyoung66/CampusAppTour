import 'package:campus_app_tour/kakao_social_login_IMPL.dart';
import 'package:campus_app_tour/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_app_tour/screen/home.dart';

class LoginScreen extends StatelessWidget {
  final viewModel = MainViewModel(KakaoSocialLogin());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.28),
          Container(
            width: 190,
            height: 120,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 50),
          SizedBox(
            width: 270,
            height: 70,
            child: ElevatedButton(
              onPressed: () async {
                await viewModel.login();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
                // SharedPreferences prefs = await SharedPreferences.getInstance();
                // print(prefs.getString('user_kakao_id'));
                // print(prefs.getString('user_profile_image_url'));
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                primary: Color(0xFFFFEC00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              child: Container(
                width: 46,
                height: 46,
                child: Image.asset(
                  'assets/images/kakao.png',
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 270,
            height: 70,
            child: ElevatedButton(
              onPressed: () {
                // 버튼2의 동작 코드
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                primary: Color(0xFF03C75A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              child: Container(
                width: 46,
                height: 46,
                child: Image.asset(
                  'assets/images/naver.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
