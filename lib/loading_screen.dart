
//video player while loading
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kitaab/Screens/home_page.dart';
import 'package:kitaab/Services/theme_provider.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}
class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late Future<void> loadHomePage;
  List<AnimationController> _controllers = [];
  

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      _controllers.add(
        AnimationController(
          duration: Duration(milliseconds: 500),
          vsync: this,
        )..repeat(),
      );
    }
    loadHomePage = Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadHomePage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [


                Text(
                  'Just a moment...',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.brown[300],


                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _controllers.map((controller) {
                    return AnimatedBuilder(
                      animation: controller,
                      child: Icon(
                        Icons.book_rounded,
                        size: 20,
                        color: Colors.brown[300],
                      ),
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: controller.value * 6.3,
                          child: child,
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        } else {
          return HomePage();
        }
      },
    );
  }
}