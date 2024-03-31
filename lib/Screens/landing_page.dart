import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LandingPage extends StatefulWidget {
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  bool isLoggedIn = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: -100, end: 270).animate(_controller);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: _animation.value,
                left: 0,
                right: 0,
                child: child!,
              );
            },
            child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset('assets/images/owl.png',
                    height: 300, width: 300)),
          ),

          // Replace with your image
          Positioned(
            top: 550,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20) ,
              child: Column(
                children: [
                  Text(
                    'Welcome to our Book Renting App. Here you can rent, buy, or sell books with ease.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Lets get started!',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    onPressed: () {
                      if (isLoggedIn) {
                        Navigator.pushNamed(context, '/home');
                      } else {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
