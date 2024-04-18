import 'package:flutter/material.dart';
import 'package:kitaab/Screens/home_page.dart';
import 'package:kitaab/Screens/landing_page.dart';
import 'package:kitaab/Screens/login.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  final bool isFreshUser;
  SplashScreen({Key? key, required this.isLoggedIn, required this.isFreshUser}
  ) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Navigate to HomePage after 4 seconds
   widget. isFreshUser ? Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginSignUpPage()),
      );
    }) :
    widget.isLoggedIn ?
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }) :
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginSignUpPage()),
      );
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  //#10000a
          Color(0xff10000a),
       // set the background color
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset('assets/icon/icon.png'),
        ),
      ),
    );
  }
}