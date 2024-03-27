import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpiPayment extends StatefulWidget {
  final String upiId;
  UpiPayment({required this.upiId}) : super();

  @override
  State<UpiPayment> createState() => _UpiPaymentState();

  void requestPayment() {}

  Future<Map<String,dynamic>> getUpiDetails() async {

    // Get UPI details from the server
    // Assuming the server returns a JSON object with the following fields

    final response = await http.post(
      Uri.parse(
          'https://upi-verification.p.rapidapi.com/v3/tasks/sync/verify_with_source/ind_vpa'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'X-RapidAPI-Key': '4a2f703050msh019fb91b2285ce8p14b799jsn1f2f962dbf99',
        'X-RapidAPI-Host': 'upi-verification.p.rapidapi.com',
      },
      body: jsonEncode(<String, dynamic>{
        'task_id': 'UUID',
        'group_id': 'UUID',
        'data': {'vpa': upiId},
      }),
    );


    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, then parse the JSON.
      print(response.body);
      
      return  jsonDecode(response.body);
    } else {
      // If the server returns an error response, then throw an exception.
      print ('Failed to load UPI details');
      print(response.body);
      return {};
    }
  }

  Future<bool> verifyUpi() async {
    try{
    final response = await http.post(
      Uri.parse(
          'https://upi-verification.p.rapidapi.com/v3/tasks/sync/verify_with_source/ind_vpa'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'X-RapidAPI-Key': '4a2f703050msh019fb91b2285ce8p14b799jsn1f2f962dbf99',
        'X-RapidAPI-Host': 'upi-verification.p.rapidapi.com',
      },
      body: jsonEncode(<String, dynamic>{
        'task_id': 'UUID',
        'group_id': 'UUID',
        'data': {'vpa': upiId},
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, then parse the JSON.
      // Assuming the API returns a JSON object with a 'valid' field
      return true;
    } else {
      // If the server returns an error response, then throw an exception.
      print('Failed to verify UPI');
      return false;
    }
    
  
  } catch (e) {
    print('Failed to verify UPI due to exception: $e');
    return false;
  }
  }
 
  
}

class _UpiPaymentState extends State<UpiPayment> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
