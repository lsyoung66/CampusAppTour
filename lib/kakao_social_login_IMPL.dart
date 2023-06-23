import 'package:campus_app_tour/kakao_social_login.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class KakaoSocialLogin implements SocialLogin {
  String serverIdAddress = "172.30.1.43";
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  @override
  Future<bool> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          prefs.setString('access_token', token.accessToken);
          loggerNoStack.w(token.toString());
          return true;
        } catch (error) {
          return false;
        }
      } else {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          prefs.setString('access_token', token.accessToken);
          loggerNoStack.w(token);
          return true;
        } catch (error) {
          return false;
        }
      }
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> withdrawal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    String accessToken = prefs.getString('access_token') ?? "";
    loggerNoStack.w("withdrawal : accessToken", accessToken);
    if (userKakaoId.isEmpty) {
      loggerNoStack.w("로그인되어있지 않음");
      return false;
    }
    try {
      Map<String, String> body = {
        'user_kakao_id': userKakaoId,
        'user_access_token': accessToken
      };
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      String url = "http://" + serverIdAddress + ":3000/withdrawal";
      http.Response response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      UserApi.instance.unlink();
      return true;
    } catch (error) {
      loggerNoStack.w(error);
      return false;
    }
  }
}
