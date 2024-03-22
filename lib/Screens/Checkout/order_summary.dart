import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    //print the items in the cart

    print('User ID: ${FirebaseAuth.instance.currentUser!.uid}');

    return Container(
      height: 400 ,
      width: double.infinity,
      child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('cart')
              .get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: '));
            }
            if (snapshot.data == null) {
              return Center(child: Text('NoI'));
            }
      
      
      
            if (snapshot.hasData) {
              final data = snapshot.data!.docs;
              
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(10) ,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        
                        title: 
                        FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('books')
                              .doc(data[index]['bid'])
                              .get(),
                          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: '));
                            }
                            if (snapshot.data == null) {
                              return Center(child: Text('NoI'));
                            }
                            if (snapshot.hasData) {
                              final book = snapshot.data!.data() as Map<String, dynamic>;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text (book['bookTitle'], style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(book['bookAuthor'], style: TextStyle(color: Colors.grey))
                                ],
                              );
                            }
                            return Center(child: Text('No'));
                          },
                        ),
                        
                        trailing: Text( 'Rs. ${data[index]['total'].toString()}'),
                      ),
                    );
                  });
            }
            return Center(child: Text('No'));
          }),
    );

  }
}
