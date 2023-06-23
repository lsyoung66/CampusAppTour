import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_app_tour/screen/mapMain.dart';
import '../kakao_social_login_IMPL.dart';
import '../main_view_model.dart';

class Reviews extends StatefulWidget {
  final void Function() callback;
  const Reviews({Key? key, required this.callback}) : super(key: key);
  @override
  State<Reviews> createState() => _ReviewState();
}

class _ReviewState extends State<Reviews> {
  final TextEditingController _textEditingController = TextEditingController();
  List<String> reviews = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(5)),
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: 25,
                decoration: BoxDecoration(
                  color: Color(0XFFFF6F00),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '- - - - - - - - - - - - - - - - - - - - -',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // 추가된 텍스트 컨테이너와의 간격
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '※리뷰를 등록하면 코스가 완료됩니다.', // 원하는 텍스트로 변경
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFFFF6F00),
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5), // 추가된 텍스트 컨테이너와의 간격
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 가로로 가운데 정렬
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(5)),
                Container(
                  width: 220,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 243, 243),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    width: 220,
                    height: 100,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "리뷰를 작성해 주세요.",
                        hintStyle: TextStyle(
                          fontSize: 15,
                        ),
                        suffixIcon: GestureDetector(
                          child: const Icon(
                            Icons.backspace,
                            color: Color(0XFFFF6F00),
                            size: 20,
                          ),
                          onTap: () => _textEditingController.clear(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 10,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0XFFFF6F00), width: 3.0),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(0, 255, 255, 255),
                              width: 3.0),
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      maxLines: 20,
                      controller: _textEditingController,
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(5)),
              ],
            ),
            const SizedBox(width: 20), // 컨테이너와 버튼 사이의 간격
            SizedBox(
              width: 50,
              height: 90,
              child: ElevatedButton(
                onPressed: () {
                  createReview();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  "등\n록",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFFFF6F00),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void createReview() async {
    final viewModel = MainViewModel(KakaoSocialLogin());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    String userAccessToken = prefs.getString('access_token') ?? "";
    String reviewContent = _textEditingController.text;
    bool success = await viewModel.addReview(
      reviewContent,
      userAccessToken, // 사용자 엑세스 토큰
      userKakaoId, // 사용자 카카오 ID
    );

    if (success) {
      // 리뷰 등록 성공
      //showAlertDialog(context);
      await viewModel.updateCourseComplete();
      print('리뷰 등록 성공');

      setState(() {
        isOrienteeringInProgress = false;
        widget.callback();
      });
    } else {
      // 리뷰 등록 실패
      print('리뷰 등록 실패');
    }
  }
}

showAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text("코스 완료!"),
        actions: [
          TextButton(
            child: Text("확인"),
            onPressed: () {
              // 확인 버튼을 눌렀을 때 수행할 작업
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
          ),
        ],
      );
    },
  );
}
