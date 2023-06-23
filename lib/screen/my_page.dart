import 'package:campus_app_tour/screen/home.dart';
import 'package:campus_app_tour/screen/review.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:campus_app_tour/kakao_social_login_IMPL.dart';
import 'package:campus_app_tour/main_view_model.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mypage extends StatefulWidget {
  const Mypage({Key? key}) : super(key: key);

  @override
  State<Mypage> createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  final viewModel = MainViewModel(KakaoSocialLogin());

  String userName = "";
  String imagePath = "";

  List<Widget> _myCompletedCourses = [];
  List<Widget> _myReviews = [];

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
    initializeMyCompletedCourses();
    initializeMyReviews();
  }

  Future<void> initializeMyCompletedCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    var completedCourses = await viewModel.getMyCompletedCourse(userKakaoId);
    if (completedCourses.isEmpty) loggerNoStack.w('null');
    for (var course in completedCourses) {
      _myCompletedCourses.add(
        ElevatedButton(
          onPressed: () {
            _showPopup(
                context, course['course_name'], course, initializeMyReviews);
          },
          child: Text(
            course['course_name'] + '코스',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 255, 161, 107),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            minimumSize: Size(80, 40),
            backgroundColor: Color.fromARGB(255, 255, 161, 107),
          ),
        ),
      );
      _myCompletedCourses.add(
        SizedBox(width: 10),
      );
    }

    setState(() {});
  }

  Future<void> initializeMyReviews() async {
    _myReviews = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userKakaoId = prefs.getString('user_kakao_id') ?? "";
    var myReviews = await viewModel.getMyReviews(userKakaoId, "0");
    if (myReviews.isEmpty) loggerNoStack.w('my Review is null');
    for (var review in myReviews) {
      _myReviews.add(
        ListTile(
          leading: CircleAvatar(
            child: Text(
              review['course_name'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Color.fromARGB(255, 255, 161, 107),
          ),
          title: Text(
            review['review_content'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showEditReviewPopUp(context, review, initializeMyReviews);
                },
                child: Text(
                  "수정",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  minimumSize: Size(80, 40),
                  backgroundColor: Color.fromARGB(255, 255, 161, 107),
                ),
              ),
              SizedBox(width: 5),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String userKakaoId = prefs.getString('user_kakao_id') ?? "";
                  String userAccessToken =
                      prefs.getString('access_token') ?? "";
                  bool isSeccessful = await viewModel.deleteReview(
                      userKakaoId, userAccessToken, review['idx'].toString());
                  print(isSeccessful);
                  if (isSeccessful) await initializeMyReviews();
                },
                child: Text(
                  "삭제",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  minimumSize: Size(80, 40),
                  backgroundColor: Color.fromARGB(255, 255, 161, 107),
                ),
              ),
            ],
          ),
        ),
      );
      _myReviews.add(
        SizedBox(height: 5),
      );
    }

    setState(() {});
  }

  Future<void> initializeSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("user_nickname") ?? "";
    String path = prefs.getString("user_profile_image_url") ?? "";

    setState(() {
      userName = name;
      imagePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pop();
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
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
              alignment: Alignment(
                  Alignment.bottomLeft.x + 2.02, Alignment.bottomLeft.y - 0.16),
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("도움말"),
                        content: Text(
                          "이 창은 도움말입니다.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            letterSpacing:
                                1.2, // Adjust the value to widen the space between letters
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Icon(Icons.help),
                backgroundColor: Colors.white,
                foregroundColor: Color(0XFFFF6F00),
              )),
          Align(
              alignment: Alignment(
                  Alignment.bottomLeft.x + 1.6, Alignment.bottomLeft.y - 0.15),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Icon(Icons.home_sharp),
                backgroundColor: Colors.white,
                foregroundColor: Color(0XFFFF6F00),
              )),
          Align(
              alignment: Alignment(Alignment.bottomLeft.x + 1.35,
                  Alignment.bottomLeft.y + 0.008),
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('앱을 종료하시겠습니까?'),
                        actions: [
                          TextButton(
                            child: Text('취소'),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: Text('확인'),
                            onPressed: () {
                              SystemNavigator.pop(); // Close the app
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(Icons.logout),
                backgroundColor: Colors.white,
                foregroundColor: Color(0XFFFF6F00),
              )),
          Align(
            alignment: Alignment(
                Alignment.bottomRight.x + 0.12, Alignment.bottomLeft.y + 0.02),
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
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 410,
                      height: 100,
                      color: Colors.white,
                      child: Row(
                          // 사진 / 중앙 / 수정버튼 컨테이너
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(imagePath),
                              ),
                            ),
                            SizedBox(
                              // Cat + 사용자 이름 표시 컨테이너
                              width: 100,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 50,
                                    child: Text(
                                      "CAT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    height: 50,
                                    child: Text(
                                      "${userName}" + "님",
                                      // "이서영" + "님",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              // 텍스트 버튼(수정) 컨테이너
                              width: 100,
                              height: 64,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {},
                                    child: Text(
                                      "수정",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFFFF6F00),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ExpansionTile(
                  iconColor: Color(0XFFFF6F00),
                  textColor: Color(0XFFFF6F00),
                  title: const Text(
                    "내가 완주한 코스",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  initiallyExpanded: false,
                  children: <Widget>[
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _myCompletedCourses,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(5))
                  ],
                ),
                ExpansionTile(
                  iconColor: Color(0XFFFF6F00),
                  textColor: Color(0XFFFF6F00),
                  title: const Text(
                    "내가 쓴 리뷰",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Container(
                      height: 380, // ListView의 높이를 설정해야 스크롤이 가능합니다.
                      child: ListView(
                        children: _myReviews,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showPopup(BuildContext context, String selectedCourse, var data,
    Future<void> Function() initializeMyReviews) {
  final viewModel = MainViewModel(KakaoSocialLogin());
  double appBarHeight = AppBar().preferredSize.height;
  bool isVerified = true;
  bool isVerified2 = false;

  final TextEditingController _textEditingController = TextEditingController();
  List<String> reviews = [];

  showDialog(
    context: context,
    barrierColor: Color.fromARGB(0, 255, 255, 255),
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: appBarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFAC00).withOpacity(0.6),
              borderRadius: BorderRadius.circular(50),
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(25, 20, 25, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color(0XFFFF6F00),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              '시간기록',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            color: Color(0xFFFF6F00),
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(50, 35, 50, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '✔ START TIME ✔\n',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: formatDateTime(data['start_time']),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                  backgroundColor:
                                      Color.fromARGB(205, 255, 255, 255),
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(50, 15, 50, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '✔ FINISH TIME ✔\n',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: formatDateTime(data['end_time']),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration:
                                      TextDecoration.none, // Keep underline
                                  backgroundColor:
                                      Color.fromARGB(205, 255, 255, 255),
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showEditReviewPopUp(BuildContext context, var review,
    Future<void> Function() initializeMyReviews) {
  final viewModel = MainViewModel(KakaoSocialLogin());
  double appBarHeight = AppBar().preferredSize.height;
  bool isVerified = true;
  bool isVerified2 = false;

  final TextEditingController _textEditingController = TextEditingController();
  List<String> reviews = [];

  showDialog(
    context: context,
    barrierColor: Color.fromARGB(0, 255, 255, 255),
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: appBarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFAC00).withOpacity(0.6),
              borderRadius: BorderRadius.circular(50),
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(25, 20, 25, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0XFFFF6F00),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              '리뷰수정',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            color: Color(0xFFFF6F00),
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(25, 50, 25, 0),
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        width: 300,
                        height: 160,
                        child: Column(
                          children: [
                            Container(
                              // 텍스트 필드
                              width: 280,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Scaffold(
                                resizeToAvoidBottomInset: false,
                                body: SizedBox(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      suffixIcon: GestureDetector(
                                        child: const Icon(
                                          Icons.backspace,
                                          color: Color(0XFFFF6F00),
                                          size: 20,
                                        ),
                                        onTap: () =>
                                            _textEditingController.clear(),
                                      ),
                                      hintText: review['review_content'],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 20.0),
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.5),
                                        borderSide: BorderSide(
                                          // Change the color to white
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0XFFFF6F00),
                                            width: 3.0),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                0, 255, 255, 255),
                                            width: 3.0),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                    ),
                                    maxLines: 20,
                                    controller: _textEditingController,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String userAccessToken =
                                await prefs.getString('access_token') ?? "";
                            String userKakaoId =
                                await prefs.getString('user_kakao_id') ?? "";
                            String reviewContent = _textEditingController.text;
                            String reviewTitle = userKakaoId + 'course Review';
                            String reviewGrade = "5.0";
                            if (reviewContent.isEmpty) {
                              showAlertDialog(context);
                            } else {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String userAccessToken =
                                  await prefs.getString('access_token') ?? "";
                              String userKakaoId =
                                  await prefs.getString('user_kakao_id') ?? "";
                              String reviewContent =
                                  _textEditingController.text;

                              bool isSuccessful = await viewModel.editReview(
                                  userKakaoId,
                                  userAccessToken,
                                  review['idx'].toString(),
                                  reviewContent);
                              if (isSuccessful) {
                                initializeMyReviews();
                                Navigator.pop(context);
                              }
                            }
                            _textEditingController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: const Text(
                            "완료",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6F00),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _addSpacingIfNecessary(String text) {
  const maxLineLength = 15; // 최대 한 줄 길이
  final words = text.split(' ');
  var currentLineLength = 0;
  final formattedWords = <String>[];

  for (var i = 0; i < words.length; i++) {
    final word = words[i];
    final wordLength = word.length;

    if (currentLineLength + wordLength > maxLineLength) {
      formattedWords.add('\n'); // 띄어쓰기 추가
      currentLineLength = 0;
    }

    formattedWords.add(word);
    currentLineLength += wordLength + 1; // 단어 길이와 띄어쓰기 길이를 더함
  }

  return formattedWords.join(' ');
}

String formatDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  String formattedDateTime = DateFormat('yyyy-MM-dd hh:mm:ss').format(dateTime);
  return formattedDateTime;
}

showAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("오류"),
        content: Text("내용을 입력해주세요."),
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
