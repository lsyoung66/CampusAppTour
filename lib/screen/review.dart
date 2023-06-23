import 'package:campus_app_tour/screen/home.dart';
import 'package:campus_app_tour/screen/review.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:campus_app_tour/kakao_social_login_IMPL.dart';
import 'package:campus_app_tour/main_view_model.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewPage extends StatefulWidget {
  final viewModel = MainViewModel(KakaoSocialLogin());
  final String courseName;

  ReviewPage({required this.courseName});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final viewModel = MainViewModel(KakaoSocialLogin());
  List<Widget> reviewList = [];

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    var reviews =
        await viewModel.getCourseReviews(filterAlphabets(widget.courseName));
    for (var review in reviews) {
      setState(() {
        reviewList.add(
          ListTile(
            title: Text(
              review['review_content'],
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        );
      });
    }
  }

  String filterAlphabets(String input) {
    // 정규식을 사용하여 영문 소문자와 대문자만 추출
    RegExp regex = RegExp('[a-zA-Z]');
    String filtered = '';

    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      if (regex.hasMatch(char)) {
        filtered += char;
      }
    }

    return filtered;
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
        children: [
          SizedBox(height: 20),
          Text(
            widget.courseName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: reviewList.length,
              itemBuilder: (context, index) {
                return reviewList[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}
