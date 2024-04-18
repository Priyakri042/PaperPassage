import 'dart:math' as math;

import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kitaab/Screens/home_page.dart';
import 'package:kitaab/Services/auth_services.dart';
import 'package:kitaab/Services/routes.dart';
import 'package:kitaab/loading_screen.dart';
import 'package:kitaab/main.dart';
import 'package:kitaab/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginSignUpPage extends StatefulWidget {
  @override
  _LoginSignUpPageState createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation = Tween<double>(begin: 120, end: 50)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  final _formKey = GlobalKey<FormState>();

  bool isSignIn = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  String? errorMessage;

  Future<void> handleGoogleSignIn(UserCredential userCredential) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);

    prefs.setBool('isFreshUser', false);
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    if (!userDoc.exists) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': userCredential.user!.displayName,
        'email': userCredential.user!.email,
      });
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoadingScreen()));
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      prefs.setBool('isFreshUser', false);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Stack(children: [
                    AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
        
                          return  Positioned(
                            top: 50,
                            bottom: 150,
                            right: 160,
                            left: _animation.value,
                            child: Bubble(
                              radius: Radius.circular(50),
                              nipOffset: 0,
                              nipWidth: 10,
                              nipHeight: 5,
                              elevation: 5,
                              shadowColor: Colors.brown[200]!,
                              color: Colors.white,
                              child:  isSignIn
                                  ? Center(
                                    child: Text(
                                        'Come on in!',
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.brown[800],fontWeight: FontWeight.bold ),),
                                  )
                                  : Center(
                                    child: Text('Join Us!',
                                        style: TextStyle(
                                            fontSize: 17, color: Color(0xFF4E342E),fontWeight: FontWeight.bold)),
                                  ),
                              padding: BubbleEdges.fromLTRB(30, 10, 30, 10),
                              margin: BubbleEdges.only(top: 10),
                              showNip: true,
                              nip: BubbleNip.rightBottom,
                            ),
                          );
                        }),
                    Container(
                      margin: EdgeInsets.only(top: 50),
                      alignment: Alignment.bottomRight,
                      width: double.infinity,
                      child: Image.asset('assets/images/owl.png',
                          height: 200, width: 200,
                          //shadow 
                          ),
                    ),
                    
                  ]),
                  
                ],
              ),
            ),
            Container(

              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
              height: 450,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown[200]!,
                    blurRadius: 10,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (!isSignIn)
                      TextFormField(
                        cursorColor: Colors.brown[800]!,
                      
                        
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Name', 
                        labelStyle: TextStyle(color: Colors.brown[800]!),
                        focusedBorder:  UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown[800]!,
                          width: 2.0),),
                          enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown[800]!,
                          ),)
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid name';
                          }
                          return null;
                        },
                      ),
                    TextFormField(
                      cursorColor: Colors.brown[800]!,
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.brown[800]!),
                      focusedBorder:  UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown[800]!,
                          width: 2.0),),
                          enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown[800]!,
                          ),)
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@') ||
                            !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                      
                        return null;
                      },
                    ),
                    TextFormField(
                      cursorColor: Colors.brown[800]!,
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.brown[800]!),
                      focusedBorder:  UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown[800]!,
                          width: 2.0),),
                          enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown[800]!,
                          ),)
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (!isSignIn) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black, backgroundColor: Colors.brown[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (!isSignIn) {
                              AuthenticationHelper()
                                  .signUp(
                                      email: emailController.text,
                                      password: passwordController.text)
                                  .then((result) async {
                                if (result == null) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString('email', emailController.text);
                                  prefs.setString('name', nameController.text);
                                  prefs.setString('profileImage', '');
                                  prefs.setBool('isLoggedIn', true);
                                  prefs.setBool('isFreshUser', false);
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth.instance.currentUser!.uid)
                                      .set({
                                    'name': nameController.text,
                                    'email': emailController.text,
                                    'profileImage': '',
                                  });
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoadingScreen()));
                                } else {
                                  print('error:' + result.toString());
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(result.toString()),
                                  ));
                                }
                              });
                            } else {
                              AuthenticationHelper()
                                  .signIn(
                                      email: emailController.text,
                                      password: passwordController.text)
                                  .then((result) async {
                                print('result: ' + result.toString());
                                if (result == null) {
                                  print('logged in...');
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('isLoggedIn', true);
                                  prefs.setBool('isFreshUser', false);
                                  prefs.setString('email', emailController.text);
                                  print('logged in...');
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoadingScreen()));
                                } else {
                                  print('error:' + result.toString());
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(result.toString()),
                                  ));
                                }
                              }).catchError(
                                (e) {
                                  print('error: ' + e.toString());
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(e.toString()),
                                  ));
                                },
                              );
                            }
                          }
                        },
                        child: isSignIn ? Text('Sign In') : Text('Sign Up'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isSignIn = !isSignIn;
                        });
                      },
                      child: isSignIn
                          ? Text('Don\'t have an account? Sign up',
                              style: TextStyle(color: Colors.brown[800],fontWeight: FontWeight.bold))
                          : Text('Already have an account? Sign in',
                              style: TextStyle(color: Colors.brown[800],fontWeight: FontWeight.bold)),
                    ),
                    Text('or', style: TextStyle(color: Color(0xFF4E342E),fontWeight: FontWeight.bold)),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black, backgroundColor: Colors.brown[200],
                          shadowColor: Colors.brown[800]!. withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            UserCredential userCredential =
                                await signInWithGoogle();
                            await handleGoogleSignIn(userCredential);
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://img.icons8.com/color/48/000000/google-logo.png',
                              height: 20,
                              width: 20,
                            ),
                            SizedBox(width: 10),
                            Text('Sign in with Google'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
