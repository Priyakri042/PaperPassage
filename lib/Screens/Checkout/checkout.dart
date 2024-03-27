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

  TextEditingController upiController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  TextEditingController bankNameController = TextEditingController();

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
              controlsBuilder: (BuildContext context, ControlsDetails details) {
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
                  title:
                      Icon(Icons.payments, size: 20, color: Colors.brown[600]),
                  content: Column(
                    children: [
                      //radio buttons for payment methods
                      //upi, card, netbanking, cash on delivery
                      const Text(
                        'PAYMENT METHOD',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        title: const Text('UPI'),
                        leading: Radio(
                          value: 'UPI',
                          groupValue: _paymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                            });
                          },
                        ),
                      ),
                      _paymentMethod == 'UPI'
                          ? Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter your UPI ID';
                                            }
                                            return null;
                                          },
                                          controller: upiController,
                                          decoration: const InputDecoration(
                                              labelText: 'UPI ID'),
                                        ),
                                      ),
                                      Positioned(
                                          right: 0,
                                          top: 25,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: _isUpiValid
                                                ? Colors.green
                                                : Colors.red,
                                          ))
                                    ],
                                  ),
                                  !_isUpiValid
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            //send payment request to UPI app

                                            //get user's UPI ID
                                            if (await UpiPayment(
                                                        upiId:
                                                            upiController.text)
                                                    .verifyUpi() ==
                                                true) {
                                              UpiPayment(
                                                      upiId: upiController.text)
                                                  .requestPayment();

                                              setState(() {
                                                _isUpiValid = true;
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Invalid UPI ID'),
                                                ),
                                              );
                                              setState(() {
                                                _isUpiValid = false;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 30,
                                              vertical: 5,
                                            ),
                                          ),
                                          child: const Text(
                                            "Verify UPI ID",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        )
                                      : Container(
                                          //details of the UPI account
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 10),

                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          height: 150,
                                          width: double.infinity,

                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'UPI ID: ${upiController.text}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Expanded(
                                                child: FutureBuilder<
                                                    Map<String, dynamic>>(
                                                  future: UpiPayment(
                                                          upiId: upiController
                                                              .text)
                                                      .getUpiDetails(),
                                                  builder: (context,
                                                      AsyncSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Text(
                                                          'Loading...');
                                                    }
                                                    if (snapshot.hasError) {
                                                      return const Text(
                                                          'Error loading UPI details');
                                                    }
                                                    if (snapshot.hasData) {
                                                      var result = snapshot
                                                          .data!['result'];
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                              'Name : ${result['name_at_bank']}',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )),

                                                          Text(
                                                              'VPA: ${result['vpa']}'),
                                                          // Add more fields as needed
                                                        ],
                                                      );
                                                    } else {
                                                      return const Text(
                                                          'No data found');
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      ListTile(
                        title: const Text('Card'),
                        leading: Radio(
                          value: 'Card',
                          groupValue: _paymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                            });
                          },
                        ),
                      ),
                      _paymentMethod == 'Card'
                          ? Column(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your card number';
                                    }
                                    if (value.length != 16) {
                                      return 'Please enter a valid 16-digit card number';
                                    }
                                    return null;
                                  },
                                  controller: cardNumberController,
                                  decoration: const InputDecoration(
                                      labelText: 'Card Number'),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your expiry date';
                                    }
                                    if (value.length != 5) {
                                      return 'Please enter a valid expiry date';
                                    }
                                    return null;
                                  },
                                  controller: expiryDateController,
                                  decoration: const InputDecoration(
                                      labelText: 'Expiry Date'),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your CVV';
                                    }
                                    if (value.length != 3) {
                                      return 'Please enter a valid 3-digit CVV';
                                    }
                                    return null;
                                  },
                                  controller: cvvController,
                                  decoration:
                                      const InputDecoration(labelText: 'CVV'),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      ListTile(
                        title: const Text('Netbanking'),
                        leading: Radio(
                          value: 'Netbanking',
                          groupValue:
                              _paymentMethod, // Use _paymentMethod instead of 'payment'
                          onChanged: (String? value) {
                            setState(() {
                              _paymentMethod = value!;
                            });
                          },
                        ),
                      ),
                      _paymentMethod == 'Netbanking'
                          ? TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your bank name';
                                }
                                return null;
                              },
                              controller: bankNameController,
                              decoration:
                                  const InputDecoration(labelText: 'Bank Name'),
                            )
                          : const SizedBox(),
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
                    ],
                  ),
                  isActive: _currentStep >= 2,
                ),
                Step(
                  state: _stepStates[3],
                  title: Icon(Icons.check_circle,
                      size: 20, color: Colors.brown[600]),
                  content: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          FirebaseFirestore firestore = FirebaseFirestore.instance;
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
                              'address': addressController.text,
                              'city': cityController.text,
                              'state': stateController.text,
                              'pincode': pincodeController.text,
                              'orderDate': //current date only
                                  DateTime.now().toIso8601String(). split('T')[0],
                              'userId': auth.currentUser!.uid,
                              'totalAmount':await  OrderSummary.getCartTotal(),
                              'paymentMethod': _paymentMethod,
                            });
                          } catch (e) {
                            print(e);
                          }

                          //send order details to the server
                          //send order details to the server

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderedDetails(orderId: orderId),
                            ),
                          );
                        },
                        child: const Text('Place Order'),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 3,
                ),
              ],
            ),
          ),
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
                  child: _currentStep <= 2
                      ? TextButton(
                          onPressed: () {
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
