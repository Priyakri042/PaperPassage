import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> addData(Map<String, dynamic> data, String collection) async {
  await FirebaseFirestore.instance.collection(collection).add(data);
}

Future<void> updateData(
    Map<String, dynamic> data, String collection, String docId) async {
  await FirebaseFirestore.instance
      .collection(collection)
      .doc(docId)
      .update(data);
}

Future<void> deleteData(String collection, String docId) async {
  await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
}

//fetch data
Future<QuerySnapshot> fetchData(String collection) async {
  return await FirebaseFirestore.instance.collection(collection).get();
}

//upload profile image
FirebaseStorage storage = FirebaseStorage.instance;
//Create a reference to the location you want to upload to in firebase
 
  ValueNotifier<bool> isUploading = ValueNotifier<bool>(false);

Future<void> uploadProfileImage(File imageFile, String userId) async {
  // Read the image
  isUploading.value = true;
  img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

  // Convert the image to jpg
  Uint8List jpg = img.encodeJpg(image!);

  // Get a reference to the storage bucket
  var storageRef = FirebaseStorage.instance.ref('profile_images/$userId.jpg');

  // Upload the file
  await storageRef.putData(jpg);

  // Get the download URL and save it in user preferences
  String downloadUrl = await storageRef.getDownloadURL();
  var prefs = await SharedPreferences.getInstance();
  await prefs.setString('profileImageUrl', downloadUrl);
  await prefs.setString('profileImageName', '$userId.jpg');
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'profileImageUrl': downloadUrl});

    // prefs.setString('profileImageUrl', downloadUrl);
    isUploading.value = false;
}

ValueListenableBuilder<bool> getUploadStatus() {
  return ValueListenableBuilder(
    valueListenable: isUploading,
    builder: (context, value, child) {
      return value
          ? Center(
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              ),
            )
          : Container();
    },
  );
}

//book details

void addBook(
  
  String uid,
  String bid,
  String bookTitle,
  String bookAuthor,
  String category,
  String forRent,
  int rentPrice,
  int price,
  String description,
  String imageUrl, stock,
  //save date and time
) async {
  //add book details to firestore with bookid as document id
  CollectionReference books = FirebaseFirestore.instance.collection('books');
  //add date and time to firestore

  await books.doc(bid).set({
    'date': DateTime.now(),
    'sellerId': uid,
    'bookTitle': bookTitle,
    'bookAuthor': bookAuthor,
    'category': category,
    'forRent': forRent,
    'rentPrice': rentPrice,
    'price': price,
    'description': description,
    'imageUrl': imageUrl,
    'bookTitleUpper': bookTitle.toUpperCase(),
    'stock': stock,
  });
}

Future<Image> getImage(uid) async {
  Map<String,dynamic> userDoc = (await FirebaseFirestore.instance.collection('users').doc(uid).get()).data()?? {};
      //if image url is not present in firestore, return default image
      if(userDoc['profileImageUrl'] == null){
        return Image.asset('assets/images/owl.png');
      }
      //if image url is present in firestore, return the image
      else{
        return Image.network(userDoc['profileImageUrl']);
      }
}

getUserDetails(uid) async {
  Map<String,dynamic> userDoc = (await FirebaseFirestore.instance.collection('users').doc(uid).get()).data()?? {};
  return userDoc;
}

getBookDetails (bid) async {
  Map<String,dynamic> bookDoc = (await FirebaseFirestore.instance.collection('books').doc(bid).get()).data()?? {};
  return bookDoc;
}
