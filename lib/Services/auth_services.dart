import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;

  // Get username and password from the user.Pass the data to
// helper method

  Future<bool> checkEmailRegistered(String email) async {
    List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
    if (signInMethods.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

//SIGN UP METHOD
  Future signUp({required String email, required String password}) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    for (var doc in querySnapshot.docs) {
      print(doc['email']);
      if (doc['email'] == email) {
        print('User already exists');
        return 'User already exists';
      }
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      // Handle error
      print(e);
      return e.toString();
    }
  }

  //SIGN IN METHOD
  Future signIn({required String email, required String password}) async {

    //check if the user exists
    bool userExists = await checkEmailRegistered(email);
    if (!userExists) {
      print('User does not exist');
      return 'User does not exist';
    }

    else{
      
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('signed in successfully');
      if (_auth.currentUser != null) {
        print('User is signed in');
        return null;
      }
      else{
        print('User is not signed in');
        return 'User is not signed in';
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'ERROR_WRONG_PASSWORD') {
        print('The password is incorrect. Please try again.');
      } else {
        print(e.message);
      }
      return e.message;
    } on PlatformException catch (e) {
      if(e.code == 'ERROR_WRONG_PASSWORD' || e.code == 'wrong-password'){
        return ('The password is incorrect. Please try again.');
      }
      if(e.code == 'ERROR_USER_NOT_FOUND' || e.code == 'user-not-found'){
        return ('User does not exist');
      }
      if(e.code == 'TOO_MANY_REQUESTS' || e.code == 'too-many-requests'){
        return ('Too many requests. Please try again later');
      }
      return e.message;
    } on Error catch (e) {
      SnackBar(content: Text(e.toString()));
      return e.toString();
    } on Exception catch (e) {
      SnackBar(content: Text(e.toString()));
      return e.toString();
    }
    }
  }
}

 