import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OrderedDetails extends StatefulWidget {
  String orderId;

  OrderedDetails({super.key, required this.orderId});

  @override
  State<OrderedDetails> createState() => _OrderedDetailsState();
}

class _OrderedDetailsState extends State<OrderedDetails>
    with TickerProviderStateMixin {
       late AnimationController scaleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
  late Animation<double> scaleAnimation = CurvedAnimation(parent: scaleController, curve: Curves.elasticOut);
  late AnimationController checkController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
  late Animation<double> checkAnimation = CurvedAnimation(parent: checkController, curve: Curves.linear);



  @override
  void initState() {
    super.initState();
    scaleController.forward();
    scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        checkController.forward();
      }
    });
  } 

  @override
  void dispose() {
    scaleController.dispose();
    checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //animation for success
          Stack(
          children: [
            Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),
            ),
            SizeTransition(
      sizeFactor: checkAnimation,
      axis: Axis.horizontal,
      axisAlignment: -1,
      child: Center(
        child: Icon(Icons.check, color: Colors.white, size: 100),
      ),
            ),
          ],
        ),
      
          Text(
            'Order Placed Successfully!',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
          SizedBox(height: 20),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('OrderDetails')
                .doc(widget.orderId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LinearProgressIndicator(),
                );
              }
      
              if (snapshot.hasError) {
                return Center(
                  child:
                      Text('An error occurred while loading order details'),
                );
              }
              if (!snapshot.hasData) {
                return Center(
                  child: Text('Empty data!'),
                );
              }
      
              if (snapshot.hasData) {
                final orderData = snapshot.data!.data() ?? {};
      
      
                return Container(
                  padding: EdgeInsets.all(20),
                  height: 200,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Order ID: ${orderData['orderId']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text('Order Date: ${orderData['orderDate']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text('Order Total: ${orderData['totalAmount']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text('No order details found!'),
                );
              }
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
            child: Text('Back to Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
