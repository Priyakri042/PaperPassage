import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitaab/main.dart';
import 'package:kitaab/navigation_bar.dart';
import 'package:marquee/marquee.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

num globalPrice = 0;

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
    await Future.delayed(Duration(milliseconds: 1000));
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
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return snapshot.data!
                  ? Center(
                      child: Text(
                          'Cart is essentially empty. Add some books to cart!'),
                    )
                  :
                  //list of books added to cart
                  SmartRefresher(
                      enablePullDown: true,
                      controller: _refreshController,
                      onRefresh: _onRefresh,

                      //pull to refresh
                      header: ClassicHeader(
                        refreshingText: 'Refreshing...',
                        failedText: 'Refresh failed',
                        idleText: 'Pull down to refresh',
                        releaseText: 'Release to refresh',
                      ),

                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Expanded(child: CartList()),
                            TotalPrice(),
                            SizedBox(
                              height: 10.0,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                //navigate to checkout page
                                Navigator.pushNamed(context, '/checkout');
                              },
                              //decorating the button
                              //height of button

                              style: ElevatedButton.styleFrom(
                                //shadow of button
                                //height of button
                                elevation: 5,
                                //background color of button

                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                textStyle: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              child: Text('Checkout',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            SizedBox(
                              height: 10.0,
                            )
                          ],
                        ),
                      ),
                    );
            }
          },
        ),
        bottomNavigationBar: bottomAppBar(),
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
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return //line progress indicator
                  const LinearProgressIndicator();
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('Cart is empty'),
              );
            }

            List<dynamic> cartItems = snapshot.data!.docs;
            print(cartItems.length);
            for (int i = 0; i < cartItems.length; i++) {
              print(cartItems[i]['bid']);
            }

            // Now you can use cartItems to build your list
            return ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('books')
                      .doc(cartItems[index]['bid'])
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return //line progress indicator
                          const LinearProgressIndicator();
                    }

                    return Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(3, 3), // changes position of shadow
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Book removed from cart')));
                        },
                        background: Container(
                            padding: EdgeInsets.only(right: 20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.brown[400],
                            ),
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.delete)),
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.0),
                                margin: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: Offset(
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
                              SizedBox(
                                  width:
                                      10), // Add some spacing between the image and the text
                              Expanded(
                                // Use Expanded to avoid overflow
                                child: Text(
                                  snapshot.data!.get('bookTitle'),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Spacer(),
                              TrailWidget(
                                price: snapshot.data!.get('price'),
                                rentPrice: snapshot.data!.get('rentPrice'),
                                isRent: cartItems[index]['isRent'],
                                bid: cartItems[index]['bid'],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ));
  }
}

class TrailWidget extends StatefulWidget {
  final bool isRent;
  int price;
  int rentPrice;
  final String bid;

  int subtotal = 0;
  int total = 0;

  TrailWidget(
      {super.key,
      required this.price,
      required this.rentPrice,
      required this.isRent,
      required this.bid});


  int days = 10;

  @override
  _TrailWidgetState createState() => _TrailWidgetState();
}

class _TrailWidgetState extends State<TrailWidget> {

@override
void initState() {
  super.initState();
  loadDays();
}


  Future<void> loadDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int days = prefs.getInt('days_${widget.bid}') ?? 10;
    setState(() {
      widget.days = days;
    });
    
  }
  @override
  Widget build(BuildContext context) {
    
    setState(() {
      if (widget.isRent) {
        widget.subtotal = widget.rentPrice;
      } else {
        widget.subtotal = widget.price;
      }
    });
   

    return widget.isRent
        ? Container(
            //get a + - button to increase or decrease the number of days
            alignment: Alignment.topRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () async {

                        setState(() {
                          //if days are greater than 10, decrease the days
                          if (widget.days > 10) {
                            widget.days -= 1;
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setInt('days_${widget.bid}', widget.days);
                            });
                            
                            FirebaseFirestore firestore = FirebaseFirestore.instance;
                            firestore
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('cart')
                                .doc(widget.bid)
                                .update({
                              'total': widget.rentPrice * widget.days
                            });
                            
                          }
                        });
                      },
                    ),
                    Text('${widget.days}'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        setState(() {
                          widget.days += 1;
                          widget.subtotal = widget.rentPrice * widget.days;

                          FirebaseFirestore firestore = FirebaseFirestore.instance;
                          firestore
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('cart')
                              .doc(widget.bid)
                              .update({
                            'total': widget.rentPrice * widget.days
                          });
                          SharedPreferences.getInstance().then((prefs) {
                              prefs.setInt('days_${widget.bid}', widget.days);


                            });
                        });
                      },
                    ),
                  ],
                ),
                Text('Rs.${widget.subtotal * widget.days}'),
              ],
            ),
          )
        : Text('Rs. ${widget.price}');
  }
}

class TotalPrice extends StatefulWidget {
  int subtotal = 0;
  
   Future<int> getSubtotal() async {
    QuerySnapshot<Map<String, dynamic>> cartItems = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cart')
        .get();

    
    for (int i = 0; i < cartItems.docs.length; i++) {
      
      subtotal += cartItems.docs[i]['total'] as int;
    }

    print('Subtotal: $subtotal\n');
    return subtotal;
  }
  @override
  _TotalPriceState createState() => _TotalPriceState();
}


class _TotalPriceState extends State<TotalPrice> {

 
  final int tax = 10;

  final int shippingCharges = 20;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: TotalPrice().getSubtotal(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        int updatedSubtotal = snapshot.data!;

        return Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal'),
                  Text('Rs. $updatedSubtotal'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax'),
                  Text('Rs. $tax'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Shipping Charges'),
                  Text('Rs. $shippingCharges'),
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total'),
                  Text('Rs. ${ 
                    snapshot.data!
                     + tax + shippingCharges}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

