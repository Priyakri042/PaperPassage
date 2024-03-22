// routes.dart
import 'package:flutter/material.dart';
import 'package:kitaab/Screens/Add/add_book.dart';
import 'package:kitaab/Screens/Book/book.dart' as bookScreen;
import 'package:kitaab/Screens/Book/new_books.dart';
import 'package:kitaab/Screens/Cart/cart.dart';
import 'package:kitaab/Screens/Settings/settings.dart';
import 'package:kitaab/Screens/History/history.dart';
import 'package:kitaab/Screens/Checkout/checkout.dart';
import 'package:kitaab/Screens/home_page.dart';
import 'package:kitaab/Screens/landing_page.dart';
import 'package:kitaab/Screens/login.dart';
import 'package:kitaab/Widgets/search.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (context) => LandingPage());
    case '/home':
      return MaterialPageRoute(builder: (context) => HomePage());
    case '/login':
      return MaterialPageRoute(builder: (context) => LoginSignUpPage());
    case '/settings':
      return MaterialPageRoute(builder: (context) => Settings());
    case '/cart':
      return MaterialPageRoute(builder: (context) => Cart());
    case '/add':
      return MaterialPageRoute(builder: (context) => AddBook());
    case '/history':
      return MaterialPageRoute(builder: (context) => History());
    case '/book':
      return MaterialPageRoute(builder: (context) => bookScreen.Book(bid: settings.arguments as String));

    case '/checkout':
      return MaterialPageRoute(builder: (context) => Checkout());

      case '/newBooks':
      return MaterialPageRoute(builder: (context) => NewBooks());

      case '/search':
  final args = settings.arguments as Map<String, String?>;
  return MaterialPageRoute(builder: (context) => Search(onSearch: args['searchTerm']!, filter: args['filterName'] ?? ''));

    default:
      return MaterialPageRoute(builder: (context) => HomePage());
  }
}