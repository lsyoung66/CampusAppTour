import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mapMain.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFloatingActionButtonVisible = true;

  void toggleFloatingActionButton() {
    setState(() {
      isFloatingActionButtonVisible = !isFloatingActionButtonVisible;
    });
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
        ),
        actions: [
          FourDotsIcon(
            size: 30,
            color: Colors.black,
            onPressed: () {
              toggleFloatingActionButton();
            },
          )
        ],
        title: Center(
          child: Image.asset(
            'assets/images/logo2.png',
            width: 150,
          ),
        ),
      ),
      body: Center(
        child: MapMain(
          isFloatingActionButtonVisible: isFloatingActionButtonVisible,
          toggleFloatingActionButton: toggleFloatingActionButton,
        ),
      ),
    );
  }
}

class FourDotsIcon extends StatelessWidget {
  final double size;
  final Color color;
  final VoidCallback? onPressed;

  FourDotsIcon({required this.size, required this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      highlightColor: Colors.transparent,
      radius: size * 2, // pressed effect
      child: CustomPaint(
        size: Size(size, size),
        painter: _FourDotsIconPainter(color),
      ),
    );
  }
}

class _FourDotsIconPainter extends CustomPainter {
  final Color color;

  _FourDotsIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final dotRadius = size.width / 8;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(dotRadius * 3, dotRadius * 10),
      dotRadius,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width - dotRadius * 10, dotRadius * 10),
      dotRadius,
      paint,
    );

    canvas.drawCircle(
      Offset(dotRadius * 3, size.height - dotRadius * 10),
      dotRadius,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width - dotRadius * 10, size.height - dotRadius * 10),
      dotRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(_FourDotsIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}