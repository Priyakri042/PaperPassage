import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitaab/Screens/Checkout/order_summary.dart';
import 'package:kitaab/main.dart';
import 'package:kitaab/navigation_bar.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // return to home page
        navigatorKey.currentState?.pushReplacementNamed('/home');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              navigatorKey.currentState?.pushReplacementNamed('/home');
            },
          ),
          title: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 600) {
                return const Text('History',
                    style: TextStyle(fontSize: 30, color: Colors.black));
              } else {
                return const Text('History',
                    style: TextStyle(fontSize: 20, color: Colors.black));
              }
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.brown[200],
        ),
        body: Container(
          child: HistoryList(),
        ),
        bottomNavigationBar: bottomAppBar(),
      ),
    );
  }
}

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: FutureBuilder(
        future: getOrderedDetails(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            print('History: ${snapshot.data!.docs.length}');
            for (var doc in snapshot.data!.docs) {
              print('Order ID: ${doc.id}');
              print('Order Date: ${doc['orderDate']}');
            }
            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (context, index) =>
                  Padding(padding: EdgeInsets.all(5)),
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown[200]!.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                      title: Text(
                          'Order ID: ${snapshot.data!.docs[index].id}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      subtitle: Text(
                          'Order Date: ${snapshot.data!.docs[index]['orderDate']}',
                          style: TextStyle(
                            color: Colors.black,
                          )),
                      trailing: Text(
                          'Total: ${snapshot.data!.docs[index]['totalAmount']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      onTap: () {
                        navigatorKey.currentState?.pushNamed('/order_history',
                            arguments: snapshot.data!.docs[index].id);
                      }),
                );
              },
            );
          }
        },
      ),
    );
  }

  getOrderedDetails() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('orders')
        .get();
  }
}
