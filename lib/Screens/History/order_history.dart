// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitaab/Screens/Book/book.dart';
import 'package:kitaab/Screens/Book/new_books.dart';
import 'package:kitaab/Screens/Cart/cart.dart';
import 'package:kitaab/Screens/Checkout/order_summary.dart';
import 'package:kitaab/Services/database_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistory extends StatefulWidget {
  String? orderId;
  OrderHistory({super.key, required this.orderId});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  var bid;
  SharedPreferences? prefs;

    

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<bool> isAlreadyReviewed(String bid) async {
    bool result = false;
    await FirebaseFirestore.instance
        .collection('books')
        .doc(bid)
        .collection('Reviews')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        result = true;
      } else {
        result = false;
      }
    });
    print ('result: $bid => $result');
    return result;
  }
  Stream<bool> isAlreadyReviewedStream(String bid) async* {
  while (true) {
    bool result = await isAlreadyReviewed(bid);
    yield result;
  }
}

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  updateReview(data, collection, docId) async {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .update(data);
  }

  Future<Map<String, dynamic>> getUserReview(bid, uid) async {
    print('bid: $bid');
    //query to get reviews of the book of the user
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('books')
        .doc(bid)
        .collection('Reviews')
        .where(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      print ('querySnapshot.docs.first.data(): ${querySnapshot.docs.first.data()}');
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  Stream<Map<String, dynamic>> getUserReviewStream(bid, uid) async* {
    while (true) {
      Map<String, dynamic> result = await getUserReview(bid, uid);
      yield result;
    }
  }

  Future<void> addReview(bid, uid, review, rate) async {
    // Get a reference to the reviews subcollection of the book
    CollectionReference reviews = FirebaseFirestore.instance
        .collection('books')
        .doc(bid)
        .collection('Reviews');

    // Add the review
    await reviews.doc(uid).set({
      'uid': uid,
      'review': review,
      'rating': rate,
      'timestamp': FieldValue.serverTimestamp(),

      // Add any other fields you need
    });
    

    SnackBar snackBar = SnackBar(content: Text('Thank you for your feedback!'));
  }

  getOrderedDetails() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('orders')
        .doc(widget.orderId)
        .collection('items')
        .get();
  }
  
  TextEditingController reviewController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  Map data = {};

  Future<bool> isReviewed () async {FirebaseFirestore.instance
      .collection('books')
      .doc('bid')
      .collection('Reviews')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      
      return true;
    } else {
      
      return false;
    }
  });
  return false;
  
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text('Items Ordered',
              style: TextStyle(color: Colors.black, fontSize: 20)),
        ),
        backgroundColor: Colors.brown[200],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: double.infinity,
        child: Column(
          children: [
            Container(
              height: 700,
              child: FutureBuilder(
                  future: getOrderedDetails(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data == null) {
                      return Container();
                    }
                    return ListView.separated(
                        itemCount: snapshot.data!.docs.length,
                        separatorBuilder: (context, index) =>
                            Padding(padding: EdgeInsets.all(5)),
                        itemBuilder: (context, index) {
                          int rate = 0;
                          
                           
                    
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[100],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown[200]!.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                    padding: EdgeInsets.all(10),
                                    child: ListTile(
                                      title: Text(
                                          snapshot.data!.docs[index]['title'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      subtitle: Text(
                                          snapshot.data!.docs[index]['author'],
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey)),
                                      trailing: Text(
                                          'Rs. ${snapshot.data!.docs[index]['total'].toString()}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 15)),
                                    )),
                                FutureBuilder(
                                  future: isAlreadyReviewed(
                                      snapshot.data!.docs[index]['bid']
                                  ),
                                  builder: (context, snapshotReviewed) {
                                    if (snapshotReviewed.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshotReviewed.data == null) {
                                      return Container();
                                    }
                                    return StreamBuilder(
                                      stream : getUserReviewStream(snapshot.data!.docs[index]['bid'], FirebaseAuth.instance.currentUser!.uid),
                                      builder: (context, reviewSnapshot) {
                                        if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (reviewSnapshot.data == null) {
                                          return Container();
                                        }
                                        ratingController.text = reviewSnapshot.data!['rating'].toString();
                                        int rate = int.parse(ratingController.text);
                                        return Container(
                                          padding: EdgeInsets.all(10),
                                      child: Container(
                                        width: double.infinity ,
                                        color: snapshotReviewed.data == true
                                            ? Colors.green[200]
                                            : Colors.orange[200],
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            child: Text(
                                              snapshotReviewed.data == true
                                                  ? 'Edit Review'
                                                  : 'Add Review',
                                              style: TextStyle(
                                                  color: Colors.brown[800],
                                                  fontWeight: FontWeight.bold),
                                            ),
                                           
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(
                                                    builder: (context, setState) {
                                                      bid = snapshot.data!.docs[index]
                                                          ['bid'];
                                                      return Dialog(
                                                        backgroundColor:
                                                            Colors.brown[200],
                                                        child: ConstrainedBox(
                                                          constraints: BoxConstraints(
                                                            maxHeight: 370,
                                                            maxWidth: double.infinity,
                                                          ),
                                                          child: AlertDialog(
                                                            backgroundColor:
                                                                Colors.brown[200],
                                                            iconPadding:
                                                                EdgeInsets.all(0),
                                                            insetPadding:
                                                                EdgeInsets.all(0),
                                                            contentPadding:
                                                                EdgeInsets.all(10),
                                                            actionsPadding:
                                                                EdgeInsets.all(0),
                                                            title: Center(
                                                                child: Text(
                                                                    'Do you like the book?',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .brown[800],
                                                                        fontSize: 20,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold))),
                                                            content: Container(
                                                              // color: Colors.brown[200],
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize.min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                      'Let us know what you think!',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                                  .brown[
                                                                              800],
                                                                          fontSize: 15,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold)),
                                                         snapshotReviewed.data == true?       Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      for (int i = 1;
                                                                          i <= 5;
                                                                          i++)
                                                                        IconButton(
                                                                          padding:
                                                                              EdgeInsets
                                                                                  .all(
                                                                                      0),
                                                                          icon: Icon(
                                                                              Icons
                                                                                  .star_rate,
                                                                              color: rate >=
                                                                                      i
                                                                                  ? Colors.yellow[
                                                                                      700]
                                                                                  : Colors
                                                                                      .grey[800],
                                                                              size: 25),
                                                                          onPressed:
                                                                              () {
                                                                                setState(() {
                                                                                  rate = i;
                                                                                  ratingController.text = i.toString();
                                                                                });
                                                                          },
                                                                        ),
                                                                    ],
                                                                  ):
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      for (int i = 1;
                                                                          i <= 5;
                                                                          i++)
                                                                        IconButton(
                                                                          padding:
                                                                              EdgeInsets
                                                                                  .all(
                                                                                      0),
                                                                          icon: Icon(
                                                                              Icons
                                                                                  .star_rate,
                                                                              color: rate >= i
                                                                                  ? Colors.yellow[
                                                                                      700]
                                                                                  : Colors
                                                                                      .grey[800],
                                                                              size: 25),
                                                                          onPressed:
                                                                              () {
                                                                           setState(() {
                                                                                  rate = i;
                                                                                  ratingController.text = i.toString();
                                                                                });
                                                                          },
                                                                        ),
                                                                    ],
                                                                  ),
                                                         snapshotReviewed.data == true?         TextField(
                                                                    controller:
                                                                        reviewSnapshot.data!['review'] == null
                                                                            ? reviewController
                                                                            : reviewController
                                                                                ..text = reviewSnapshot.data!['review'],
                                                                    maxLines: 5,
                                                                    cursorHeight: 30,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      focusColor: Colors
                                                                          .brown[800],
                                                                      hintText:
                                                                          'Write a review',
                                                                      hintStyle: TextStyle(
                                                                          color: Colors
                                                                              .white),
                                                                      border:
                                                                          InputBorder
                                                                              .none,
                                                                      fillColor: Colors
                                                                          .brown[800],
                                                                      filled: true,
                                                                    ),
                                                                  ): Text(
                                                                      reviewSnapshot.data!['review'],
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                                  .brown[
                                                                              800],
                                                                          fontSize: 15,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold)),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  //add in map
                                                                   snapshotReviewed == true
                                                                      ? updateReview(
                                                                          {
                                                                            'review':
                                                                                reviewController
                                                                                    .text,
                                                                            'rating':
                                                                                rate,
                                                                          },
                                                                          'books/${snapshot.data!.docs[index]['bid']}/Reviews',
                                                                          bid,
                                                                        )
                                                                      : addReview(
                                                                          snapshot.data!
                                                                                      .docs[
                                                                                  index]
                                                                              ['bid'],
                                                                          FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid,
                                                                          reviewController
                                                                              .text,
                                                                          rate);
                                                                  print('Review added');
                                                                  SnackBar snackBar =
                                                                      SnackBar(
                                                                          content: Text(
                                                                              'Thank you for your feedback!'));

                                                                  ScaffoldMessenger.of( context)
                                                                      .showSnackBar(snackBar);
                                                                            
                                                                  Navigator.pop(
                                                                      context);
                                                                      
                                                                },
                                                                child: Text(
                                                                  'Submit',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .brown[800],
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          
                                          ),
                                          
                                        ],
                                      ),
                                                                        ),
                                    );
                                  },
                                );
                                  },
                                  ),
                              
                              ],
                            ),
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
