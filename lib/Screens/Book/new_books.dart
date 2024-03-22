import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kitaab/Screens/home_page.dart';
import 'package:kitaab/main.dart';

class NewBooks extends StatelessWidget {
  const NewBooks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                return const Text('Recent Arrivals',
                    style: TextStyle(fontSize: 30, color: Colors.black));
              } else {
                return const Text('Recent Arrivals',
                    style: TextStyle(fontSize: 20, color: Colors.black));
              }
            },
          ),
          backgroundColor: Colors.brown[200],
          centerTitle: true,
        ),
        body: Column(
          children: [
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('books')
                  .orderBy('bookTitle')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot books = snapshot.data!.docs[index];
                      return Container(
                        child: Card(
                          child: ListTile(
                            leading: Image.network(books['imageUrl']),
                            title: Text(books['bookTitle']),
                            subtitle: Text(books['bookAuthor']),
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                Navigator.pushNamed(context, '/book',
                                    arguments: books.id);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ));
  }
}
