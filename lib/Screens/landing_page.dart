import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  bool isLoggedIn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: const Text('Kitaab Junction')),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/owl.png'),
               // Replace with your image
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Welcome to our Book Renting App. Here you can rent, buy, or sell books with ease.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                child: const Text('Lets get started!'),
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
    );
  }
}