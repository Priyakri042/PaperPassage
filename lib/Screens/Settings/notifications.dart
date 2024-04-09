import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kitaab/Screens/History/order_history.dart';
import 'package:kitaab/Screens/History/sellerInfo.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {


   


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.brown[200],
      ),
      body: Container(
        child:FutureBuilder(
          future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).
          collection('soldBooks').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final documents = snapshot.data!.docs;
            final uniqueOrderIds = documents.map((doc) => doc['orderId']).toSet().toList();

           
            
      return ListView.builder(
        itemCount: uniqueOrderIds.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.brown[200],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text('Order ID: ${uniqueOrderIds[index]}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              // subtitle:  Text('Date: ${snapshot.data!.docs[index]['OrderDate']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                //fetch data from order history where sellerId is current user id and orderId is uniqueOrderIds[index]
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return OrderHistorySeller (buyerId:  snapshot.data!.docs[index]['buyerId']
                    , orderId: uniqueOrderIds[index]);
              }
            ));
            
              },
            ),
          );
        },
      );
    },
  ),
),
    );
  }
}
      