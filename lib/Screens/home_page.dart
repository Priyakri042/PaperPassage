// import 'package:firebase_auth/firebase_auth.ropart';
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
                      return SizedBox(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator(
                          color: Colors.brown,
                          //small circular progress indicator
                        ),
                      );
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
                            decoration: BoxDecoration(
                              color: Colors.brown[200],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.brown,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    print(userId);
    //fetch user name from firestore
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // return to home page
        navigatorKey.currentState?.pushReplacementNamed('/home');
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
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
                                    child: const CircularProgressIndicator());
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
                          Flexible(
                            fit: FlexFit.loose,
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search for books',
                                  hintStyle: TextStyle(
                                    color: Colors.brown[500],
                                    shadows: const [
                                      Shadow(
                                        color: Colors.grey,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  )),
                              onSubmitted: (value) {
                                Navigator.pushNamed(context, '/search',
                                    arguments: {
                                      'searchTerm': value,
                                      'filterName': _filterName,
                                    });
                              },
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.filter_list,
                              color: Colors.brown,
                              shadows: [
                                Shadow(
                                  color: Colors.grey,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'Action',
                                child: Text('Action'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Fantasy',
                                child: Text('Fantasy'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Horror',
                                child: Text('Horror'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Romance',
                                child: Text('Romance'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Science Fiction',
                                child: Text('Science Fiction'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Thriller',
                                child: Text('Thriller'),
                              ),
                            ],
                            onSelected: (String value) {
                              _filterName = value;
                            },
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
                            child:  Text(
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
                            return SizedBox(
                              height: 20,
                              width: 20,
                              child: const CircularProgressIndicator(
                                color: Colors.brown,
                                //small circular progress indicator
                              ),
                            );
                          }
                          return Container(
                            height: 250,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(10),
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
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
                  height: 270,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(3),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      String category = categories[index];
                      Image imagePath = images[category]!;
                      return Container(
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
                        child: InkWell(
                          //background image

                          splashColor: Colors.brown[200],
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            _showModalBottomSheet(context, categories[index]);
                          },
                          child: Center(
                            child: Text(
                              categories[index],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //clicable book card
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/book', arguments: book.bid);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  child: Image.network(
                    book.imageUrl,
                    height: 100,
                    fit: BoxFit.cover,
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
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
              Flexible(
                  child: book.forRent == 'Rent'
                      ? Text(
                          ' \Rs.${(book.rentPrice).toInt().toString()}/day',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        )
                      : Text(
                          ' \Rs. ${book.price.toString()}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        )),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
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
    );
  }
}
