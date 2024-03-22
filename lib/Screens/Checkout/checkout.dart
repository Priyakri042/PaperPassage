import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitaab/Screens/Cart/cart.dart';
import 'package:kitaab/Screens/Cart/cart.dart';
import 'package:kitaab/Screens/Checkout/order_summary.dart';

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
                return 
                const SizedBox.shrink(  );
              },
              steps: [
                Step(
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
                  state: _currentStep >= 0
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
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
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
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
                  state: _currentStep >= 1
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
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
                          ? TextFormField(
                              decoration: const InputDecoration(labelText: 'UPI ID'),
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
                                  decoration:
                                      const InputDecoration(labelText: 'Card Number'),
                                ),
                                TextFormField(
                                  decoration:
                                      const InputDecoration(labelText: 'Expiry Date'),
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'CVV'),
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
                              decoration:
                                  const InputDecoration(labelText: 'Bank Name'),
                            )
                          : const SizedBox(),
                      ListTile(
                        title: const Text('Cash on Delivery'),
                        leading: Radio(
                          value: 'Cash on Delivery',
                          groupValue:
                              _paymentMethod, // Use _paymentMethod instead of 'payment'
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
                  state: _currentStep >= 2
                      ? StepState.complete
                      : StepState.disabled,
                ),
                Step(
                  title: Icon(Icons.check_circle,
                      size: 20, color: Colors.brown[600]),
                  content: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          //place order
                          //add order to orders collection
                          //add order to user's orders
                          //navigate to cart
                        },
                        child: const Text('Place Order'),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 3,
                  state: _currentStep >= 3
                      ? StepState.complete
                      : StepState.disabled,
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
                  child: TextButton(
                    onPressed: _currentStep > 0
                        ? () => setState(() => _currentStep -= 1)
                        : null,
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (_currentStep == 0) {
                        //validate address
                        //if valid, move to next step
                        setState(() => _currentStep += 1);
                      } else if (_currentStep == 1) {
                        //validate payment method
                        //if valid, move to next step
                        setState(() => _currentStep += 1);
                      }
                      else if (_currentStep == 2) {
                        //validate payment method
                        //if valid, move to next step
                        setState(() => _currentStep += 1);
                      }
                    },
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
                  ],
                ),
    );
  }
}
