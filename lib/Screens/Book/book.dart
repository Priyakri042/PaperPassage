// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, sort_child_properties_last

import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitaab/Services/database_services.dart';
import 'package:kitaab/main.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Book extends StatefulWidget {
  final String bid;

  Book({Key? key, required this.bid, Object? book}) : super(key: key);

  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  //function to get image of the book
  final PanelController _panelController = PanelController();

  var rating;

  bool isHeartPressed = false;

  noOfBooksRead() {
    return FirebaseFirestore.instance
        .collection('books')
        .doc(widget.bid)
        .get()
        .then((value) => value.data()!['noOfBooksRead']);
  }

  Future<Widget> getBookImage(String bid) async {
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

  getReviews(bid) async {
    var reviews = await FirebaseFirestore.instance
        .collection('books')
        .doc(bid)
        .collection('Reviews')
        .get();
    List<Map<String, dynamic>> reviewList = [];
    reviews.docs.forEach((element) {
      reviewList.add(element.data());
    });
    return reviewList;
  }

//   Future<Map<String, List<dynamic>>> getReviewDetails() async {
//   var book = await FirebaseFirestore.instance
//       .collection('books')
//       .doc(widget.bid)
//       .get();

// }

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
                  return const Text('Book Details',
                      style: TextStyle(fontSize: 30, color: Colors.black));
                } else {
                  return const Text('Book Details',
                      style: TextStyle(fontSize: 20, color: Colors.black));
                }
              },
            ),
            //three dots icon to show more options

            centerTitle: true,
            backgroundColor: Colors.brown[200],
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.5),
                        spreadRadius: 10,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        height: 170,
                        width: 120,
                        child: FutureBuilder(
                          future: getBookImage(widget.bid),
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return snapshot.data!;
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox();
                            }
                            return SizedBox();
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                              future: getBookDetails(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(); // or some other widget while waiting
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Container(
                                    width: 150,
                                    child: Text(
                                      snapshot.data.data()['bookTitle'],
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown[800]),
                                    ),
                                  );
                                }
                              },
                            ),

                            //               //book author
                            FutureBuilder(
                              future: getBookDetails(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(); // or some other widget while waiting
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text(
                                    snapshot.data.data()['bookAuthor'],
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              },
                            ),

                            
                          ],
                        ),
                      ),
                      //         Spacer(),
                      Container(
                        height: 170,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                //add to wishlist
                                isHeartPressed
                                    ? FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('wishlist')
                                        .doc(widget.bid)
                                        .set({
                                        'bid': widget.bid,
                                      })
                                    : FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('wishlist')
                                        .doc(widget.bid)
                                        .delete();
                                setState(() {
                                  isHeartPressed = !isHeartPressed;
                                });
                                //snackbar to show book added to wishlist
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Book added to wishlist'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: isHeartPressed
                                  ? Icon(Icons.favorite, color: Colors.red)
                                  : Icon(Icons.favorite_border,
                                      color: Colors.red),
                            ),
                            Spacer(),
                            FutureBuilder(
                                future: getBookDetails(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(); // or some other widget while waiting
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    int stock = snapshot.data.data()['stock'];
                                    return Text(
                                      stock > 0
                                          ? stock > 5
                                              ? 'In Stock'
                                              : 'Only $stock left'
                                          : 'Out of Stock',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.red[800],
                                          fontWeight: FontWeight.bold),
                                    );
                                  }
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // //book title
              SizedBox(
                height: 20,
              ),

              //book description in paragraph
              Text(
                'Description',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: FutureBuilder(
                  future: getBookDetails(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LinearProgressIndicator(
                          backgroundColor: Colors.brown
                              .withOpacity(0.5)); // or some other widget while waiting
                      
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            child: DescriptionTextWidget(
                                text: snapshot.data!['description']),
                          ));
                    }
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200]),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                height: 230,
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Reviews',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.brown[800],
                                fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                        ],
                      ),
                      Container(
                        height: 250,
                       
                        child: FutureBuilder(
                          future: getReviews(widget.bid),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(); // or some other widget while waiting
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.data == null ||
                                snapshot.data == 0) {
                              return Text('No reviews yet');
                            } else {
                              return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  print(snapshot.data);
                                  DateTime reviewDate = snapshot.data[index]
                                          ['timestamp']
                                      .toDate();
                                  DateTime now = DateTime.now();

                                  String displayDate;
                                  if (reviewDate.year == now.year &&
                                      reviewDate.month == now.month &&
                                      reviewDate.day == now.day) {
                                    displayDate = 'Today';
                                  } else {
                                    displayDate =
                                        reviewDate.toString().substring(0, 10);
                                  }
                                  return Container(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            FutureBuilder(
                                                future: getImage(snapshot
                                                    .data[index]['uid']),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return SizedBox(); // or some other widget while waiting
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return CircleAvatar(
                                                      radius: 17,
                                                      backgroundImage:
                                                          snapshot.data.image,
                                                      backgroundColor:
                                                          Colors.brown[800],
                                                    );
                                                  }
                                                }),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                FutureBuilder(
                                                    future: getUserDetails(
                                                        snapshot.data[index]
                                                            ['uid']),
                                                    builder:
                                                        (BuildContext context,
                                                            AsyncSnapshot
                                                                snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return SizedBox(); // or some other widget while waiting
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      } else {
                                                        return Text(
                                                          snapshot.data['name'],
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        );
                                                      }
                                                    }),
                                                Row(
                                                  children: [
                                                    for (int i = 0; i < 5; i++)
                                                      Icon(
                                                        Icons.star,
                                                        color: snapshot.data[
                                                                        index]
                                                                    ['rating'] >
                                                                i
                                                            ? Colors.yellow[800]
                                                            : Colors.grey[800],
                                                        size: 13,
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Text(
                                              //date of review
                                              displayDate,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[800]),
                                            )
                                          ],
                                        ),
                                        Container(
                                          padding:
                                              EdgeInsets.fromLTRB(45, 0, 0, 0),
                                          child: Text(
                                            snapshot.data[index]['review'],
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[800]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              //a rectangular card that shows these no.of people have read this book with stacked images of users
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: Column(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          //stacked images of users
                          FutureBuilder(
                              future: noOfBooksRead(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(); // or some other widget while waiting
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  int i, snapshotLength = snapshot.data ?? 0;

                                  return snapshot.data == 0 ||
                                          snapshot.data == null
                                      ? Text(
                                          'No one has read this book yet',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.brown),
                                        )
                                      : Container(
                                          width: 350,
                                          child: Row(children: [
                                            Text(
                                              'No.of people have read this book',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.brown[800]),
                                            ),
                                            Spacer(),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              height: 20,
                                              width: 50,
                                              child: Stack(
                                                children: [
                                                  for (i = 0;
                                                      i <
                                                          (snapshotLength <= 3
                                                              ? snapshotLength
                                                              : 3);
                                                      i++)
                                                    Positioned(
                                                      left: i.toDouble() * 10,
                                                      child: CircleAvatar(
                                                        radius: 10,
                                                        backgroundImage:
                                                            AssetImage(
                                                          'assets/images/owl.png',
                                                        ),
                                                        backgroundColor:
                                                            Colors.brown[800],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            snapshot.data > 0 &&
                                                    snapshot.data <= 3
                                                ? Container()
                                                : Text(
                                                    '+${snapshot.data - i}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.grey),
                                                  ),
                                          ]),
                                        );
                                }
                              }),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),

              //show rating of the book\
              // Spacer(),

              SizedBox(
                height: 10,
              ),
              //a button to buy the book
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                              .doc(firebaseAuth.currentUser!.uid)
                              .get();
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(firebaseAuth.currentUser!.uid)
                              .collection('cart')
                              .doc(widget.bid)
                              .set({
                            'bid': widget.bid,
                            'price': await getBookDetails()
                                .then((value) => value.data()!['price']),
                            'rentPrice': await getBookDetails()
                                .then((value) => value.data()!['rentPrice']),
                            'isRent': isRent,
                            'total': isRent
                                ? await getBookDetails().then(
                                    (value) => value.data()!['rentPrice'] * 10)
                                : await getBookDetails()
                                    .then((value) => value.data()!['price']),
                          });

                          //snackbar to show book added to cart
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Book added to cart'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            //pop to home page
                            navigatorKey.currentState?.pushReplacementNamed('/home');
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.brown),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.brown),
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
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(); // or some other widget while waiting
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    if (snapshot.data.data()['forRent'] ==
                                        'Sell') {
                                      isRent = false;

                                      return Text(
                                        'Buy',
                                        style: TextStyle(fontSize: 15),
                                      );
                                    } else if (snapshot.data
                                            .data()['forRent'] ==
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
                                              color: Colors.brown,
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
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(); // or some other widget while waiting
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
          )),
    );
  }

  //a button to read the book
}

class DescriptionTextWidget extends StatefulWidget {
  final String text;

  DescriptionTextWidget({required this.text});

  @override
  _DescriptionTextWidgetState createState() => _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  late String firstHalf;
  late String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 50) {
      firstHalf = widget.text.substring(0, 230);
      secondHalf = widget.text.substring(50, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: secondHalf.isEmpty
          ? Text(firstHalf)
          : Column(
              children: <Widget>[
                Text(flag ? (firstHalf + "...") : (firstHalf + secondHalf),
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic)),
                InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        flag ? "show more" : "show less",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      flag = !flag;
                    });
                  },
                ),
              ],
            ),
    );
  }
}
