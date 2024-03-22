import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kitaab/Screens/home_page.dart';
import 'package:kitaab/Services/auth_services.dart';
import 'package:kitaab/Services/routes.dart';
import 'package:kitaab/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginSignUpPage extends StatefulWidget {
  @override
  _LoginSignUpPageState createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  bool isSignIn = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  String? errorMessage;

  Future<void> handleGoogleSignIn(UserCredential userCredential) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
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
    Navigator.pushReplacementNamed(context, '/home');
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

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
      throw e;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: isSignIn
            ? Center(child: Text('Sign In'))
            : Center(child: Text('Sign Up')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!isSignIn)
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
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
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if(!isSignIn){
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (!isSignIn) {
                        AuthenticationHelper()
                            .signUp(
                                email: emailController.text,
                                password: passwordController.text)
                            .then((result) async {
                          if (result == null) {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString('email', emailController.text);
                            prefs.setString('name', nameController.text);
                            prefs.setString('profileImage', '');
                            prefs.setBool('isLoggedIn', true);
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
                                    builder: (context) => HomePage()));
                          } else {
                            print('error:' + result.toString());
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool('isLoggedIn', true);
                          prefs.setString('email', emailController.text);
                          print('logged in...');
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        } else {
                          print('error:' + result.toString());
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result.toString()),
                          ));
                        }
                      }).catchError(
                        (e) {
                          print('error: ' + e.toString());
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                    ? Text('Don\'t have an account? Sign up')
                    : Text('Already have an account? Sign in'),
              ),
              Text('or'),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      UserCredential userCredential = await signInWithGoogle();
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
    );
  }
}
