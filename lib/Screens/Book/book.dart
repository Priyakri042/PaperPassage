// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, sort_child_properties_last

import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitaab/main.dart';

class Book extends StatefulWidget {
  final String bid;
  const Book({Key? key, required this.bid, Object? book}) : super(key: key);

  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  //function to get image of the book
  Future<Widget> getImage(String bid) async {
    var url = await FirebaseFirestore.instance
        .collection('books')
        .doc(bid)
        .get()
        .then((value) => value.data()!['imageUrl']);
    return Image.network(url);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getBookDetails() async {
    var book = await FirebaseFirestore.instance
        .collection('books')
        .doc(widget.bid)
        .get();
    return book;
  }

  bool isRent = false;

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
                return const Text('Book Details', style: TextStyle(fontSize: 30, color: Colors.black));
              } else {
                return const Text('Book Details', style: TextStyle(fontSize: 20, color: Colors.black));
              }
            
            },
          ),
          centerTitle: true,
          actions: const [
            //triple dot
            Icon(Icons.more_vert, color: Colors.black, size: 30.0),
          ],
          backgroundColor: Colors.brown[200],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(80, 10, 80, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors. grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.5),
                      spreadRadius: 10,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: FutureBuilder(
                      future: getImage(widget.bid),
                      builder:
                          (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return snapshot.data!;
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  ),
                ),
              ),
            ),
            //book title
            SizedBox(
              height: 10,
            ),
      
            FutureBuilder(
              future: getBookDetails(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // or some other widget while waiting
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    snapshot.data.data()['bookTitle'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                }
              },
            ),
      
            //book author
            FutureBuilder(
              future: getBookDetails(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // or some other widget while waiting
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    snapshot.data.data()['bookAuthor'],
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  );
                }
              },
            ),
      
            //book description in paragraph
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: FutureBuilder(
                    future: getBookDetails(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // or some other widget while waiting
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          snapshot.data.data()['description'],
                          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            //a rectangular card that shows these no.of people have read this book with stacked images of users
            Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Text('Have read this book '),
                        Spacer(),
                        //stacked images of users
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/images/logo.png'),
                        ),
                        Text('+5 more'),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
      
            //show rating of the book
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: const <Widget>[
                      Column(
                        children: [
                          Text(
                            '4.5 ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rating',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow),
                          Icon(Icons.star, color: Colors.yellow),
                          Icon(Icons.star, color: Colors.yellow),
                          Icon(Icons.star, color: Colors.yellow),
                          Icon(Icons.star_half_outlined, color: Colors.yellow),
                        ],
                      ),
                      Spacer(),
                      //no.of people who have rated the book
                      Text(
                        '  100 ',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      
            SizedBox(
              height: 10,
            ),
            //a button to buy the book
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                        DocumentSnapshot document = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(firebaseAuth. currentUser!.uid )
                            .get();
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(firebaseAuth.currentUser!.uid)
                            .collection('cart')
                            .doc(widget.bid)
                            .set({
                              'bid': widget.bid,
                          'price': await getBookDetails().then(
                              (value) => value.data()!['price']),
                          'rentPrice': await getBookDetails().then(
                              (value) => value.data()!['rentPrice']),
                          'isRent': isRent,
                          'total' : isRent ? await getBookDetails().then(
                              (value) => value.data()!['rentPrice'] * 10) : await getBookDetails().then(
                              (value) => value.data()!['price']),
                         
                        });
      
                        //snackbar to show book added to cart
                        if(mounted){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Book added to cart'),
                            duration: const Duration(seconds: 2),
                          ),
                          
                        );
                        //pop to home page
                        Navigator.pop(context);}
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors. brown),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors. brown),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //if book is for sale then show only buy button
                          //if book is for rent then show only rent button
                          //if book is for both then show both buttons
                          FutureBuilder(
                              future: getBookDetails(),
                              builder:
                                  (BuildContext context, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // or some other widget while waiting
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  if (snapshot.data.data()['forRent'] == 'Sell') {
                                    isRent = false;
      
                                    return Text(
                                      'Buy',
                                      style: TextStyle(fontSize: 15),
                                    );
                                  } else if (snapshot.data.data()['forRent'] ==
                                      'Rent') {
                                    isRent = true;
                                    return Text(
                                      'Rent',
                                      style: TextStyle(fontSize: 15),
                                    );
                                  } else
                                    return Container(
                                      child: Row(children: [
                                        //if both buy and rent are available
                                        //show dropdown button to select buy or rent
                                        DropdownButton(
                                          //label: Text('Select'),
                                          //no border,
                                          icon: Icon(Icons.arrow_drop_down),
                                          dropdownColor: Colors.grey[800],
                                          padding: EdgeInsets.all(0),
                                          underline: Container(
                                            color: Colors. brown,
                                          ),
      
                                          value: isRent ? 'Rent' : 'Buy',
                                          items: const [
                                            DropdownMenuItem(
                                              child: Text(
                                                'Buy',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                              value: 'Buy',
                                            ),
                                            DropdownMenuItem(
                                              child: Text(
                                                'Rent',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                              value: 'Rent',
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value == 'Buy') {
                                              isRent = false;
                                            } else {
                                              isRent = true;
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      ]),
                                    );
                                }
                              }),
      
                          Icon(Icons.shopping_bag, size: 15),
                          Spacer(),
                          FutureBuilder(
                              future: getBookDetails(),
                              builder:
                                  (BuildContext context, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // or some other widget while waiting
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  if (isRent) {
                                    return Text(
                                        'Rs. ${snapshot.data.data()['rentPrice']}/day',
                                        style: TextStyle(fontSize: 15));
                                  } else {
                                    return Text(
                                        'Rs. ${snapshot.data.data()['price']}',
                                        style: TextStyle(fontSize: 15));
                                  }
                                }
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    //a button to read the book
  }
}
