import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

 static Future<QuerySnapshot> getCartDetails() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cart')
        .get();
  }

  Future getBookDetails(String bid) async {
    return await FirebaseFirestore.instance.collection('books').doc(bid).get();
  }

  static Future<num> getCartTotal() async {
    num? total = 0;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cart')
        .get();

    if (snapshot.docs.length == 0) {
      return 0;
    }

    for (var doc in snapshot.docs) {
      total = total! + doc['total'];
    }

    print('Total: $total');
    return total!;
  }

  @override
  Widget build(BuildContext context) {
    //print the items in the cart

    print('User ID: ${FirebaseAuth.instance.currentUser!.uid}');

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 640,
      child: Column(
        children: [
          FutureBuilder(
            future: getCartDetails(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: FutureBuilder(
                          future:
                              getBookDetails(snapshot.data!.docs[index]['bid']),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: SizedBox());
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data['bookTitle'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(snapshot.data['bookAuthor'],
                                      style: TextStyle(
                                        fontSize: 12,
                                      )),
                                ],
                              );
                            }
                          },
                        ),
                        // subtitle: Text(snapshot.data!.docs[index]['']),
                        trailing: Text(
                            snapshot.data!.docs[index]['total'].toString(),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                );
              }
            },
          ),
          Container(
            padding: EdgeInsets.all(10) ,
            child: Divider(
              thickness: 1,
              color: Colors.grey,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10) ,
            width: double.infinity,
            // height: 100,
            child: FutureBuilder(
              future: getCartTotal(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text('Subtotal', style: TextStyle(fontSize: 15)),
                          Spacer(),
                          Text(snapshot.data.toString(),
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Shipping', style: TextStyle(fontSize: 15)),
                          Spacer(),
                          Text('40', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Tax', style: TextStyle(fontSize: 15)),
                          Spacer(),
                          Text('20', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      Row(
                        children: [
                          Text('Total',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Text((snapshot.data + 60).toString(),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
