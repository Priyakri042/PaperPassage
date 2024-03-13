import 'package:flutter/material.dart';
import 'package:kitaab/Screens/Add/add_book.dart';
import 'package:kitaab/Screens/Cart/cart.dart';
import 'package:kitaab/Screens/History/history.dart';
import 'package:kitaab/Screens/Settings/settings.dart';
import 'package:kitaab/Screens/home_page.dart';
import 'Services/routes.dart';
import 'main.dart';

BottomNavigationBar BtmNavigationBar() {
   
  return BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        
        icon: Icon(Icons.home, color: Colors.black),
        
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart, color: Colors.black),
        label: 'Cart',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_rounded, color: Colors.black),
        label: 'Add',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history, color: Colors.black),
        label: 'History',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings, color: Colors.black),
        label: 'Settings',
      ),
    ],
    
    selectedItemColor: Colors.black,
    
    onTap: (index) {
      


      switch (index) {
        case 0:
          //show label
          
          navigatorKey.currentState?.pushNamed('/home');
          break;
        case 1:
          navigatorKey.currentState?.pushNamed('/cart');
          break;
        case 2:
          navigatorKey.currentState?.pushNamed('/add');
          break;
        case 3:
          navigatorKey.currentState?.pushNamed('/history');
          break;
        case 4:
          navigatorKey.currentState?.pushNamed('/settings');
          break;
      }
    },
  );
}
