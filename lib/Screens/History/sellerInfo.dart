// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitaab/Screens/Book/book.dart';
import 'package:kitaab/Screens/Book/new_books.dart';
import 'package:kitaab/Screens/Cart/cart.dart';
import 'package:kitaab/Screens/Checkout/order_summary.dart';
import 'package:kitaab/Services/database_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistorySeller extends StatefulWidget {
  String? orderId;
  String? buyerId;
  OrderHistorySeller({super.key, required this.buyerId, required this.orderId});

  @override
  State<OrderHistorySeller> createState() => _OrderHistorySellerState();
}

class _OrderHistorySellerState extends State<OrderHistorySeller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: true,
        backgroundColor: Colors.brown[200],
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('OrderDetails')
                .doc(widget.orderId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.brown[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Buyer ID: ${widget.buyerId}',style: TextStyle(fontWeight:FontWeight.bold , color:Colors.black,fontSize: 15)),
                        Text('Buyer Name: ${snapshot.data!['name']}',style: TextStyle(fontWeight:FontWeight.bold , color:Colors.black,fontSize: 15)),
                        Text('Buyer Phone: ${snapshot.data!['phone']}',style: TextStyle(fontWeight:FontWeight.bold , color:Colors.black,fontSize: 15)),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                  'Address: ${snapshot.data!['address']}, ${snapshot.data!['city']}, ${snapshot.data!['state']
                                  },  ${snapshot.data!['pincode']}',style: TextStyle(fontWeight:FontWeight.bold , color:Colors.black,fontSize: 15)),
                            ),
                          ],
                        )
                  
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.buyerId)
                .collection('orders')
                .doc(widget.orderId)
                .collection('items')
                .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final documents = snapshot.data!.docs;
              return Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Book ID: ${documents[index]['bid']}',style: TextStyle(fontWeight:FontWeight.bold , color:Colors.black)),
                                Text('Title: ${documents[index]['title']}',style: TextStyle(fontWeight:FontWeight.bold , color:Colors.black)),
                                Text('Author: ${documents[index]['author']}',style: TextStyle(fontWeight:FontWeight.bold , color:Colors.black)),
                                Text('Price: ${documents[index]['total']}',style: TextStyle(fontWeight:FontWeight.bold , color:Colors.black)),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20,)
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return Book(bid: documents[index]['bid']);
                          }
                        )
                    );
                  },
                
                
              );
            },

          ),
        );
      },
          ),

    ],
  ),

    );
  }
}


