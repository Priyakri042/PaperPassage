import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitaab/main.dart';
import 'package:kitaab/navigation_bar.dart';
import 'package:marquee/marquee.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

num globalPrice = 0;

class Cart extends StatefulWidget {
  Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
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
                return const Text('Cart', style: TextStyle(fontSize: 30, color: Colors.black));
              } else {
                return const Text('Cart', style: TextStyle(fontSize: 20, color: Colors.black));
              }
            },
            
          ),
          centerTitle: true,
          //swipe down to refresh
                    backgroundColor: Colors.brown[200],

        ),
        body:
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
                Spacer(),
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
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  child:
                      Text('Checkout', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 10.0,
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: bottomAppBar(),
      ),
    );
  }
}

class CartList extends StatelessWidget {
  late int days = 10;

  CartList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        child:
            //list of books added to cart collection from firestore
            StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return LinearProgressIndicator();
            }

            List<dynamic> cartItems = snapshot.data!.get('cart') ?? [];

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
                      height: 120,
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
                              .update({
                            'cart': FieldValue.arrayRemove([cartItems[index]])
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
                                margin: EdgeInsets. all(5.0),
                                decoration:
                                    BoxDecoration(borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                    )
                                    ,
                                child: Image.network(
                                  snapshot.data!.get('imageUrl'),
                                  width: 50,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  //border radius for image
                                  
                                ),
                              ),
                              SizedBox(
                                  width:
                                      10), // Add some spacing between the image and the text
                              Expanded(
                                // Use Expanded to avoid overflow
                                child: Text(snapshot.data!.get('bookTitle'),style: TextStyle(
                                  color: Colors.black, fontWeight:  FontWeight.bold
                                ) ,),
                              ),
                              Spacer(),
                              TrailWidget(
                                price: snapshot.data!.get('price'),
                                rentPrice: snapshot.data!.get('rentPrice'),
                                isRent: cartItems[index]['isRent'],
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

int days = 10;

class TotalPrice extends StatefulWidget {
  TotalPrice({Key? key}) : super(key: key);

  @override
  State<TotalPrice> createState() => _TotalPriceState();
}

class _TotalPriceState extends State<TotalPrice> {
  final int tax = 10;

  final int shippingCharges = 20;
  num subtotal = 0;
  void initState() {
    super.initState();
    updateSubtotal();
  }

  void updateSubtotal() async {
    num newSubtotal = await getSubtotal();
    print('newSubtotal: $newSubtotal');
    if (mounted) {
      setState(() {
        subtotal = newSubtotal;
      });
    }
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return FutureBuilder<num>(
          future: getSubtotal(),
          builder: (BuildContext context, AsyncSnapshot<num> subtotalSnapshot) {
            if (subtotalSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (subtotalSnapshot.hasError) {
              return Text('Error: ${subtotalSnapshot.error}');
            }

            num subtotal = subtotalSnapshot.data ?? 0;

            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal'),
                      Text('Rs. $subtotal'),
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
                      Text('Rs. ${subtotal + tax + shippingCharges}'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Future<num> getSubtotal() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  num subtotal = 0;
  DocumentSnapshot userSnapshot = await firestore
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  if (userSnapshot.exists) {
    List<dynamic> cartItems = userSnapshot.get('cart') ?? [];
    for (int i = 0; i < cartItems.length; i++) {
      DocumentSnapshot bookSnapshot =
          await firestore.collection('books').doc(cartItems[i]['bid']).get();

      if (bookSnapshot.exists) {
        if (cartItems[i]['isRent']) {
          subtotal += bookSnapshot.get('rentPrice') * days;
        } else {
          subtotal += bookSnapshot.get('price');
        }
      }
    }
  }

  return subtotal;
}

class TrailWidget extends StatefulWidget {
  final bool isRent;
  int price;
  int rentPrice;

  TrailWidget(
      {super.key,
      required this.price,
      required this.rentPrice,
      required this.isRent});

  @override
  _TrailWidgetState createState() => _TrailWidgetState();
}

class _TrailWidgetState extends State<TrailWidget> {
  num subtotal = 0;

  get isRent => widget.isRent;

  @override
  void initState() {
    super.initState();
    updateSubtotal();
  }

  void updateSubtotal() async {
    num newSubtotal = widget.isRent ? widget.rentPrice * days : widget.price;
    print('newSubtotal: $newSubtotal');
    setState(() {
      subtotal = newSubtotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isRent == true)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    //call setDays method from cart.dart
                    if (days > 10) days--;
                    globalPrice = widget.rentPrice * days;
                    print('globalPrice: $globalPrice');
                    updateSubtotal();
                  });
                },
                icon: days > 10
                    ? Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                      )
                    : Icon(
                        Icons.remove_circle,
                        color: Colors.grey,
                      ),
              ),
              Text(
                '$days days',
                style: TextStyle(fontSize: 15.0,
                color: Colors.black),

              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    //call setDays method from cart.dart
                    days++;
                    globalPrice = widget.rentPrice * days;
                    print('globalPrice: $globalPrice');
                    updateSubtotal();
                  });
                },
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        if (widget.isRent)
          Text(
            'Rs. ${widget.rentPrice * days} (${widget.rentPrice}/day)',
            style: TextStyle(fontSize: 15.0,
            color: Colors.black),
          ),
        if (!widget.isRent)
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: Text(
              'Rs. ${widget.price}',
              style: TextStyle(fontSize: 15.0),
            ),
          ),
      ],
    );
  }
}
