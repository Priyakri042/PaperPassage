import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kitaab/Screens/Add/add_book.dart';
import 'package:kitaab/Screens/Cart/cart.dart';
import 'package:kitaab/Screens/History/history.dart';
import 'package:kitaab/Screens/Settings/settings.dart';
import 'package:kitaab/Screens/home_page.dart';
import 'package:kitaab/Services/database_services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/routes.dart';
import 'main.dart';

int _selectedIndex = 0;

void _onItemTapped(int index) {
  _selectedIndex = index;

  if (index == 0) {
    navigatorKey.currentState!.pushReplacementNamed('/home');
  }
  if (index == 1) {
    navigatorKey.currentState!.pushReplacementNamed('/cart');
  }
  if (index == 2) {
    navigatorKey.currentState!.pushReplacementNamed('/add');
  }
  if (index == 3) {
    navigatorKey.currentState!.pushReplacementNamed('/history');
  }
  if (index == 4) {
    navigatorKey.currentState!.pushReplacementNamed('/settings');
  }
}

BottomAppBar bottomAppBar() {
  SharedPreferences prefs;
  return BottomAppBar(
      color: Colors.brown[200],
      height: 75,
      padding: EdgeInsets.zero,
      elevation: 0.0,
      child: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: false,
        elevation: 0.0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.brown[200],
            icon: Icon(Icons.home, color: Colors.brown[800]),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.brown[200],
            icon: Icon(Icons.shopping_cart, color: Colors.brown[800]),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.brown[200],
            icon: Icon(Icons.library_add_rounded, color: Colors.brown[800]),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.brown[200],
            icon: Icon(Icons.history, color: Colors.brown[800]),
            label: 'History',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.brown[200],

            //profile image
            icon: FutureBuilder<String>(
              future: getImage(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // or some placeholder
                } else {
                  if (snapshot.hasError)
                    return Icon(Icons.error); // or some error widget
                  else
                    return FutureBuilder<String>(
                      future: getImage(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // or some placeholder
                        } else {
                          if (snapshot.hasError)
                            return Icon(Icons.error); // or some error widget
                          else
                            return Stack(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.brown[800],
                                ),
                                Positioned(
                                  top: 2,
                                  left: 2,
                                  right: 2,
                                  bottom: 2,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundImage: NetworkImage(snapshot.data!) ??
                                      AssetImage('assets/images/owl.png') as ImageProvider,
                                  ),
                                ),
                              ],
                            );
                        }
                      },
                    );
                }
              },
            ),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ));
}
