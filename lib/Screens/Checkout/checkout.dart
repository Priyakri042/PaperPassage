// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitaab/Screens/Cart/cart.dart';
import 'package:kitaab/Screens/Cart/cart.dart';
import 'package:kitaab/Screens/Checkout/order_summary.dart';
import 'package:http/http.dart' as http;
import 'package:kitaab/Screens/Checkout/ordered_details.dart';
import 'package:kitaab/Screens/Checkout/upi.dart';
import 'package:uuid/uuid.dart';

import '../Cart/cart.dart';

class Checkout extends StatefulWidget {
  Checkout({Key? key}) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'UPI';
  bool _isUpiValid = false;

  final List<StepState> _stepStates = [
    StepState.indexed,
    StepState.indexed,
    StepState.indexed,
    StepState.indexed
  ];
  

  Future<void> _onStepContinue() async {
    if (_currentStep < _stepStates.length) {
      if (_currentStep == 0 || _currentStep == 1) {
        setState(() {
          _stepStates[_currentStep] = StepState.indexed;
          _currentStep++;
        });
        return;
      }

      if (_currentStep == 2 || _paymentMethod == "Cash on Delivery") {
        print('Placing order...');
        setState(() {
          _stepStates[_currentStep] = StepState.complete;
          _currentStep++;
        });
        return;
      }

      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        setState(() {
          _stepStates[_currentStep] = StepState.complete;
          _currentStep++;

        });
      } else {
        setState(() {
          _stepStates[_currentStep] = StepState.error;
        });
      }
    }
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.brown[200],
        centerTitle: true,
      ),
      body:
          //show the checkout details like address, payment method, etc
          Column(
        children: [
          Expanded(
              flex: 3,
              child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  //remove numbers from steps by setting controlsBuilder to null
                  controlsBuilder:
                      (BuildContext context, ControlsDetails details) {
                    return const SizedBox.shrink();
                  },
                  steps: [
                    Step(
                      state: _stepStates[0],
                      title: Icon(Icons.shopping_cart,
                          size: 20, color: Colors.brown[600]),
                      content: const Column(
                        children: [
                          Text(
                            'ORDER SUMMARY',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          //show order summary
                          //show items in cart
                          //show total amount
                          //show shipping charges
                          //show total amount to be paid
                          //show payment options
                          //show place order button

                          //show items in cart
                          OrderSummary(),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      state: _stepStates[1],
                      title: Icon(Icons.location_on,
                          size: 20, color: Colors.brown[600]),
                      content: Column(
                        children: [
                          const Text(
                            'SHIPPING INFO',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: nameController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      labelText: 'Name',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                  ),
                                ),
                                Padding(padding: 
                                const EdgeInsets.all(8.0),
                                child:TextFormField(
                                  keyboardType: TextInputType.phone,
                                  controller: phoneController,
                                  validator: (value) {
                                    if (value!.isEmpty || value.length != 10) {
                                      return 'Enter a valid phone number';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    labelText: 'Mobile Number',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.phone),
                                  ),
                                ),
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: addressController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      labelText: 'Address',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.home),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: cityController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your city';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      labelText: 'City',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_city),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: stateController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your state';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      labelText: 'State',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.map),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: pincodeController,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your pincode';
                                      } else if (value.length != 6) {
                                        return 'Please enter a valid 6-digit pincode';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      labelText: 'Pincode',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.pin_drop),
                                    ),
                                  ),

                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                    ),
                    Step(
                      state: _stepStates[2],
                      title: Icon(Icons.payments,
                          size: 20, color: Colors.brown[600]),
                      content: Column(
                         mainAxisAlignment: MainAxisAlignment.center ,
                         crossAxisAlignment: CrossAxisAlignment.center ,
                        children: [
                        //radio buttons for payment methods
                        //upi, card, netbanking, cash on delivery
                        const Text(
                          'PAYMENT METHOD',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 50,
                        ),

                        ListTile(
                          title: const Text('Cash on Delivery'),
                          leading: Radio(
                            value: 'Cash on Delivery',
                            groupValue: _paymentMethod,
                            onChanged: (String? value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //show address 
                        FutureBuilder(future: 
                        FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Address').doc('address').get(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data!.data() as Map<String, dynamic>;
                            return Container(
                              padding: const EdgeInsets.all(10),
                              height: 150,
                              width: double.infinity ,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10) ,
                                border: Border.all(color: Colors.grey, width: 1),
                                color: Colors.grey[200],
                                 boxShadow: [
                                  BoxShadow(
                                    color: Colors.brown[200]!.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3), // changes position of shadow
                                  ),]
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name: ${data['name']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text ('Phone: ${data['phone']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('Address: ${data['address']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('City: ${data['city']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('State: ${data['state']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('Pincode: ${data['pincode']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          } else {
                            return const Text('No address found');
                          }
                        }),
                        SizedBox(height: 100),

                      
                        Container(
                          width: double.infinity, 
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              elevation: 5 ,
                              
                              backgroundColor: Colors.green[400],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                            ),
                            onPressed: () async {
                              FirebaseFirestore firestore =
                                  FirebaseFirestore.instance;
                              FirebaseAuth auth = FirebaseAuth.instance;
                              String orderId = //short id
                                  Uuid().v4().toString().substring(0, 8);
                              try {
                                firestore
                                    .collection('OrderDetails')
                                    .doc(orderId)
                                    .set({
                                  'orderId': orderId,
                                  'name': nameController.text,
                                  'phone': phoneController.text,
                                  'address': addressController.text,
                                  'city': cityController.text,
                                  'state': stateController.text,
                                  'pincode': pincodeController.text,
                                  'orderDate': //current date only
                                      DateTime.now()
                                          .toIso8601String()
                                          .split('T')[0],
                                  'userId': auth.currentUser!.uid,
                                  'totalAmount':
                                      await OrderSummary.getCartTotal() + 60,
                                  'paymentMethod': _paymentMethod,

                                });

                                //update stock of books
                                  

                                //add order details to user's orders collection
                                
                          
                                firestore
                                    .collection('users')
                                    .doc(auth.currentUser!.uid)
                                    .collection('orders')
                                    .doc(orderId)
                                    .set({
                                  'orderId': orderId,
                                  'orderDate': DateTime.now()
                                      .toIso8601String()
                                      .split('T')[0],
                                  'totalAmount':
                                      await OrderSummary.getCartTotal() + 60,
                                  'status': 'Placed',
                                });
                          
                                var cartDetails =
                                    await OrderSummary.getCartDetails();
                          
                                for (var doc in cartDetails.docs) {
                                  String bookId = doc['bid'];
                          
                                  Map<String, dynamic> bookDetails =
                                      (await firestore
                                              .collection('books')
                                              .doc(bookId)
                                              .get())
                                          .data() as Map<String, dynamic>;
                          
                                  Map<String, dynamic> bookData = await firestore
                                      .collection('users')
                                      .doc(auth.currentUser!.uid)
                                      .collection('cart')
                                      .doc(doc.id)
                                      .get()
                                      .then((value) =>
                                          value.data() as Map<String, dynamic>);
                          
                                  firestore
                                      .collection('users')
                                      .doc(auth.currentUser!.uid)
                                      .collection('orders')
                                      .doc(orderId)
                                      .collection('items')
                                      .doc(bookId)
                                      .set({
                                    'bid': bookId,
                                    'title': bookDetails['bookTitle'],
                                    'author': bookDetails['bookAuthor'],
                                    'total': bookData['total'] + 60,
                                  });
                          
                                  //increase the no.of books read according to the bookId
                                  firestore
                                      .collection('books')
                                      .doc(bookId)
                                      .update({
                                    'noOfBooksRead': FieldValue.increment(1),
                                    'stock': bookDetails['stock'] - 1,
                                  });
                                }
                          
                                //clear the cart
                                firestore
                                    .collection('users')
                                    .doc(auth.currentUser!.uid)
                                    .collection('cart')
                                    .get()
                                    .then((snapshot) {
                                  for (DocumentSnapshot doc in snapshot.docs) {
                                    doc.reference.delete();
                                  }
                                });
                              } catch (e) {
                                print(e);
                              }
                          
                              //send order details to the server
                              //send order details to the server
                          
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderedDetails(orderId: orderId),
                                ),
                              );
                            },
                            child: const Text('Place Order'),
                          ),
                        ),
                      ]),
                      isActive: _currentStep >= 2,
                    ),
                  ])),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: _currentStep > 0
                      ? TextButton(
                          onPressed: _currentStep > 0
                              ? () => setState(() => _currentStep -= 1)
                              : null,
                          child: const Text('Back'),
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: _currentStep < 2
                      ? TextButton(
                          onPressed: () {
                            if (_currentStep == 1) {
                              setState(() {
                                FirebaseFirestore firestore =
                                    FirebaseFirestore.instance;

                                FirebaseAuth auth = FirebaseAuth.instance;

                                firestore
                                    .collection('users')
                                    .doc(auth.currentUser!.uid)
                                    .collection('Address')
                                    .doc('address')
                                    .set({
                                  'name': nameController.text,
                                  'phone': phoneController.text,
                                  'address': addressController.text,
                                  'city': cityController.text,
                                  'state': stateController.text,
                                  'pincode': pincodeController.text,
                              });
                              print ('Address added');
                              });
                              _onStepContinue();
                              
                            } else
                            if (_currentStep < _stepStates.length) {
                              _onStepContinue();
                            }
                          },
                          child: const Text('Next'),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
