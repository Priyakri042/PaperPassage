import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  String onSearch;
  String filter;

  Search({super.key, required this.onSearch, required this.filter});

  // String generateShortForm(String title) {
  //   List<String> words = title.split(' ');
  //   String shortForm = '';
  //   for (String word in words) {
  //     if (word.isNotEmpty) {
  //       shortForm += word[0].toUpperCase();
  //     }
  //   }
  //   return shortForm;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('books')
            .where('bookTitle', isGreaterThanOrEqualTo: onSearch,
                isLessThan: onSearch + 'z'
                )
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
    print('Error: ${snapshot.error}');
  }
  if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
  }
         
          return ListView.builder(
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
          );
        },
      ),
    );
  }
}
