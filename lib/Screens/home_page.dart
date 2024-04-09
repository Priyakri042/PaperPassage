// import 'package:firebase_auth/firebase_auth.ropart';
import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:kitaab/Screens/Book/book.dart';
import 'package:kitaab/main.dart';
import 'package:kitaab/navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitaab/Services/database_services.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, Image> images = <String, Image>{
    'Action': Image.asset('assets/images/Category/action.jpg'),
    'Fantasy': Image.asset('assets/images/Category/fantasy.jpg'),
    'Horror': Image.asset('assets/images/Category/horror.jpg'),
    'Romance': Image.asset('assets/images/Category/romance.jpg'),
    'Science Fiction':
        Image.asset('assets/images/Category/science-fiction.jpeg'),
    'Thriller': Image.asset('assets/images/Category/thriller.jpg'),
  };

  TextEditingController searchController = TextEditingController();

  String? _filterName;

  bool isChanged = false;

  void _showModalBottomSheet(BuildContext context, String category) {
    //show the books in that particular category
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (builder) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            widthFactor: 1,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$category Genre ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('books')
                      .where('category', isEqualTo: category)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    }
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of items in a row
                          crossAxisSpacing: 20, // Horizontal gap between items
                          mainAxisSpacing: 20, // Vertical gap between items
                          childAspectRatio: 2 / 3,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document =
                              snapshot.data!.docs[index];
                          Book book = Book.getBookDetails(document);
                          return Container(
                            child: BookCard(book: book),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<String> getUserName() async {
    //fetch user name from firestore
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var user = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.get('name');
      } else {
        return 'User';
      }
    });
    return user;
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good\nMorning,';
    }
    if (hour < 17) {
      return 'Good\nAfternoon,';
    }
    return 'Good\nEvening,';
  }

  List<String> categories = [
    'Action',
    'Fantasy',
    'Horror',
    'Romance',
    'Science Fiction',
    'Thriller'
  ];

  Stream<QuerySnapshot> filteredBookStream = Stream.empty();

  filterBooks(TextEditingController searchTerm) {
    //filter books based on search term
    if (searchTerm.text.isNotEmpty) {
      setState(() {
        isChanged = true;
        filteredBookStream = FirebaseFirestore.instance
            .collection('books')
            .where('bookTitleUpper',
                isGreaterThanOrEqualTo: searchTerm.text.toUpperCase())
            .where('bookTitleUpper',
                isLessThan: searchTerm.text.toUpperCase() + 'z')
            .snapshots();
      });
    } else {
      setState(() {
        isChanged = false;
      });
    }
  }

  final TextEditingController _controller = TextEditingController();

  StreamController<String> _searchController = StreamController<String>();
  void initState() {
    super.initState();

    _controller.addListener(() {
      filterBooks(_controller);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[300],
                                ),
                              ),
                              const SizedBox(height: 10),
                              FutureBuilder<String>(
                                future: getUserName(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  // Check if the Future is resolved
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    // If we got an error
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    // If we got our data
                                    return Text(
                                      snapshot.data ?? '',
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  // If the Future is still running
                                  else {
                                    return SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Container());
                                  }
                                },
                              )
                            ],
                          ),
                          const Spacer(),
                          const Image(
                            image: AssetImage('assets/images/owl.png'),
                            height: 150,
                          ),
                        ],
                      ),
                    ),

                    //a search bar with filter icon at the end
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.brown,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Icon(
                                Icons.search,
                                color: Colors.brown,
                                shadows: [
                                  Shadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(
                                    color: Colors.brown,
                                  ),
                                  controller: _controller,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchController.add(value);
                                      isChanged = true;
                                      filterBooks(_controller);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search for books',
                                    hintStyle: const TextStyle(
                                      color: Colors.brown,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'New Arrivals',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/newBooks');
                                },
                                child: Text(
                                  'View all',
                                  style: TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          // row of new books cards with horizontal scroll

                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('books')
                                .orderBy('date', descending: true)
                                .limit(5)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return const Text('Something went wrong');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox();
                              }
                              return Container(
                                height: 250,
                                child: ListView.separated(
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(width: 3),
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    DocumentSnapshot document =
                                        snapshot.data!.docs[index];
                                        
                                    Book book = Book.getBookDetails(document);
                                    return BookCard(book: book);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    //a category section
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('What\'s Your Genre?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),

                    Container(
                      height: 278,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(3),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3 / 2.1,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (BuildContext context, int index) {
                          String category = categories[index];
                          Image imagePath = images[category]!;
                          return InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imagePath.image,
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.5),
                                      BlendMode.darken),
                                ),
                                color: Colors.brown[
                                    200], // Change this to your desired background color
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors
                                      .brown, // Change this to your desired border color
                                  width:
                                      2, // Change this to your desired border width
                                ),

                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.brown,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                //faded background

                                backgroundBlendMode: BlendMode.darken,
                              ),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    _showModalBottomSheet(context, category);
                                  },
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              _showModalBottomSheet(context, category);
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            isChanged
                ? Positioned(
                    top: 220,
                    left: 0,
                    right: 0,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: filteredBookStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox();
                        }
                        return Positioned(
                          top: 220,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.withOpacity(0.5),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.brown[100]!, Colors.black],
                              ),
                            ),
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 2,
                                    sigmaY: 2,
                                    tileMode: TileMode.clamp),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(10),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    DocumentSnapshot document =
                                        snapshot.data!.docs[index];
                                    Book book = Book.getBookDetails(document);

                                    return
                                        //if no books found
                                        snapshot.data!.docs.length == 0
                                            ? Container(
                                                child: Center(
                                                  child: Text('No books found',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                ),
                                              )
                                            : Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.brown[100],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black,
                                                      blurRadius: 5,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                        context, '/book',
                                                        arguments: book.bid);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        book.title,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      book.forRent == 'Rent'
                                                          ? Text(
                                                              ' \Rs.${(book.rentPrice).toInt().toString()}/day',
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                            )
                                                          : Text(
                                                              ' \Rs. ${book.price.toString()}',
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    height: 0,
                    width: 0,
                  ),
          ],
        ),
        bottomNavigationBar: bottomAppBar(),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  BookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 200,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.brown[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.brown,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        child: Container(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            book.imageUrl,
                            height: 100,
                            fit: BoxFit.cover,
                           //filter color
                            color: book.stock == 0 ? Colors.grey : null,
                            colorBlendMode: book.stock == 0
                                ? BlendMode.saturation
                                : BlendMode.dstATop,
                          ),
                        ),
                      ),
                    ),
                    //book title and price
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                height: 50,
                                child: Marquee(
                                  text: book.title + ' by ' + book.author,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: book.stock == 0
                                        ? Colors.grey[800]
                                        : Colors.black,
                                  ),
                                  scrollAxis: Axis.vertical,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 5.0,
                                  velocity: 10.0,
                                  //pause after 2 rounds
                                  startAfter: const Duration(seconds: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                book.stock == 0? 
                    Text(
                      'Out of stock',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    )
                    :
                   Flexible(
                        child: book.forRent == 'Rent'
                            ? Text(
                                ' \Rs.${(book.rentPrice).toInt().toString()}/day',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: book.stock == 0
                                      ? Colors.grey[800]
                                      : Colors.black,
                                ),
                              )
                            : Text(
                                ' \Rs. ${book.price.toString()}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: book.stock == 0
                                      ? Colors.grey[800]
                                      : Colors.black,
                                ),
                              )),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: book.stock == 0 ? Colors.grey : Colors.brown[100],
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.brown,
                  blurRadius: 3,
                  offset: Offset(0, 3),
                ),
              ],
            )),
        // on tap navigate to book details page
        onTap: () {
          book.stock == 0
              ? ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Book out of stock'),
                  ),
                )
              : Navigator.pushNamed(context, '/book', arguments: book.bid);
        },
      ),
    );
  }
}

class Book {
  String bid;
  String title;
  String author;
  String category;
  String forRent;
  int price;
  String description;
  String imageUrl;
  DateTime date;
  int rentPrice;
  int stock;

  Book({
    required this.bid,
    required this.title,
    required this.author,
    required this.category,
    required this.forRent,
    required this.rentPrice,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.stock,
  });

  //data from firestore

  static Book getBookDetails(DocumentSnapshot document) {
    return Book(
      bid: document.id,
      title: document.get('bookTitle'),
      author: document.get('bookAuthor'),
      category: document.get('category'),
      forRent: document.get('forRent'),
      rentPrice: document.get('rentPrice'),
      price: document.get('price'),
      description: document.get('description'),
      imageUrl: document.get('imageUrl'),
      date: (document.get('date') as Timestamp).toDate(),
      stock: document.get('stock'),
    );
  }
}
