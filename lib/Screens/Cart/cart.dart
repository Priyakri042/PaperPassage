// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitaab/Services/database_services.dart';
import 'package:kitaab/main.dart';
import 'package:kitaab/navigation_bar.dart';
import 'package:marquee/marquee.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget {
  Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  Future<bool> isCart() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cart')
        .get();

    if (userSnapshot.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {});
    _refreshController.refreshCompleted();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                return const Text('Cart',
                    style: TextStyle(fontSize: 30, color: Colors.black));
              } else {
                return const Text('Cart',
                    style: TextStyle(fontSize: 20, color: Colors.black));
              }
            },
          ),
          centerTitle: true,
          //swipe down to refresh
          backgroundColor: Colors.brown[200],
        ),
        body: FutureBuilder<bool>(
          future: isCart(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return snapshot.data!
                  ? const Center(
                      child: Text(
                          'Cart is essentially empty. Add some books to cart!'),
                    )
                  :
                  //list of books added to cart
                  Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Expanded(child: CartList()),
                          TotalPrice(),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const SizedBox(
                            height: 10.0,
                          )
                        ],
                      ),
                    );
            }
          },
        ),
        // bottomNavigationBar: bottomAppBar(),
      ),
    );
  }
}

class CartList extends StatelessWidget {
  late int days = 10;

  CartList({super.key});
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('cart')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return //line progress indicator
                  const SizedBox();
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('Cart is empty'),
              );
            }

            List<dynamic> cartItems = snapshot.data!.docs;
            print(cartItems.length);
            for (int i = 0; i < cartItems.length; i++) {
              print(cartItems[i]['bid']);
            }

            // Now you can use cartItems to build your list
            return Container(
              margin: const EdgeInsets.all(10.0),
              child: ListView.separated(
                padding: const EdgeInsets.all(10.0),
                itemCount: cartItems.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 10.0,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('books')
                        .doc(cartItems[index]['bid'])
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return //line progress indicator
                            const SizedBox();
                      }

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown[200]!.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(
                                  3, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Dismissible(
                          key: Key(cartItems[index]
                              ['bid']), // Unique key for Dismissible
                          onDismissed: (direction) {
                            // Remove the item from the cart in Firestore
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('cart')
                                .doc(cartItems[index]['bid'])
                                .delete()
                                .then((value) => {
                                      print('Book removed from cart'),
                                    });

                            // Show a snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Book removed from cart')));
                          },
                          background: Container(
                              padding: const EdgeInsets.only(right: 20.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.brown[400],
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(Icons.delete)),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5.0),
                                  margin: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Image.network(
                                    snapshot.data!.get('imageUrl'),
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    //border radius for image
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        10), // Add some spacing between the image and the text
                                Expanded(
                                  // Use Expanded to avoid overflow
                                  child: Text(
                                    snapshot.data!.get('bookTitle'),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                Expanded(
                                  child: TrailWidget(
                                    price: snapshot.data!.get('price'),
                                    rentPrice: snapshot.data!.get('rentPrice'),
                                    isRent: cartItems[index]['isRent'],
                                    bid: cartItems[index]['bid'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ));
  }
}

class TrailWidget extends StatefulWidget {
  final int price;
  final int rentPrice;
  final bool isRent;
  final String bid;

  TrailWidget(
      {required this.price,
      required this.rentPrice,
      required this.isRent,
      required this.bid});

  @override
  State<TrailWidget> createState() => _TrailWidgetState();
}

class _TrailWidgetState extends State<TrailWidget> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late int days = 10;
  late int subtotal = widget.isRent ? widget.rentPrice * days : widget.price;

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference cart = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cart')
        .doc(widget.bid);
    return FutureBuilder<DocumentSnapshot>(
        future: cart.get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LinearProgressIndicator(
                backgroundColor: Colors.brown[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors
                    .brown[400]!)); // Show a loading spinner while waiting
          } else if (snapshot.hasError) {
            return Text(
                'Error: ${snapshot.error}'); // Show error message if something went wrong
          } else {
            // The Future has completed successfully, we can now access the data
            Map<String, dynamic>? data =
                snapshot.data!.data() as Map<String, dynamic>?;

            if (widget.isRent) {
              return Container(
                height: 100,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //want a drop down menu to select the number of days starting from 10 days
                    widget.isRent
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 30,
                                  alignment: Alignment.center,
                                  child: Text(
                                    data!['days'] == null
                                        ? '10 days'
                                        : '${data['days']} days',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.calendar_month,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.brown[400],
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    elevation: 3,
                                    shadowColor: Colors.brown,
                                    splashFactory: InkRipple.splashFactory,
                                     

                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      
                                      context: context,
                                      isDismissible: true,
                                      builder: (BuildContext context) {
                                        return Container(
                                          color: Colors.white,
                                          height: 250,
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              const Text(
                                                'Select the number of days',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10.0),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.brown[200]!
                                                          .withOpacity(0.5),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: const Offset(
                                                          3, 3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                height: 100,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: CupertinoPicker(
                                                  itemExtent: 30,
                                                  onSelectedItemChanged:
                                                      (int index) {
                                                    days = index + 10;
                                                  },
                                                  children: List.generate(
                                                      21,
                                                      (index) => Text(
                                                            '${index + 10} days',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20.0,
                                                            ),
                                                          )),
                                                ),
                                              ),
                                              Spacer(),
                                              ElevatedButton(
                                                onPressed: () {
                                                  firestore
                                                      .collection('users')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .collection('cart')
                                                      .doc(widget.bid)
                                                      .set(
                                                    {
                                                      'days': days,
                                                      'total':
                                                          widget.rentPrice *
                                                              days
                                                    },
                                                    SetOptions(merge: true),
                                                  );

                                                  Navigator.pop(context);
                                                },
                                                child:  Text(
                                                  'Save',
                                                  style: TextStyle(
                                                      color: Colors.brown[200],
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                
                              ],
                            ),
                          )
                        : Container(),
                    Text(
                      widget.isRent
                          ? '₹${data!['total'] == null ? widget.rentPrice * days : '${data['total']} (${data['rentPrice']}/day) '}'
                          : '₹${widget.price}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data!['total'] == null
                        ? '₹${widget.price}'
                        : '₹${data['total']}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
          }
        });
  }
}

class TotalPrice extends StatelessWidget {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('cart')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return //line progress indicator
                const SizedBox();
          }

          if (snapshot.data!.docs.isEmpty) {
            return const SizedBox();
          }

          List<dynamic> cartItems = snapshot.data!.docs;
          int? total = 0;
          for (int i = 0; i < cartItems.length; i++) {
            total = total != null
                ? total + cartItems[i]['total']
                : cartItems[i]['total'];
          }

          return Container(
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.brown[200]!.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(3, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${total!}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.brown,
                  thickness: 1,
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            //clear the cart
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('cart')
                                .get()
                                .then((snapshot) {
                              for (DocumentSnapshot ds in snapshot.docs) {
                                ds.reference.delete();
                              }
                            });
                          },
                          //decorating the button
                          //height of button

                          style: ElevatedButton.styleFrom(
                            //shadow of button
                            //height of button
                            elevation: 10,
                            //background color of button

                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          child: const Text('Clear Cart',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            //navigate to checkout page
                            Navigator.pushNamed(context, '/checkout');
                          },
                          //decorating the button
                          //height of button

                          style: ElevatedButton.styleFrom(
                            //shadow of button
                            //height of button
                            elevation: 10,
                            backgroundColor: Colors.green[600],

                            //background color of button

                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          child: const Text('Checkout',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
