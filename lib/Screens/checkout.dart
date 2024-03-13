
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Checkout extends StatelessWidget {
   Checkout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 600) {
              return Text('Checkout');
            } else {
              return Text('Checkout');
            }
          },
        ),
        centerTitle: true,
      ),
      body: 
      //show the checkout details like address, payment method, etc
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Checkout',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}