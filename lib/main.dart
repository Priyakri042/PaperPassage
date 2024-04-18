import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kitaab/Screens/home_page.dart';
import 'package:kitaab/Screens/login.dart';
import 'package:kitaab/Services/routes.dart';
import 'package:kitaab/Services/theme_provider.dart';
import 'package:kitaab/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final ScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool isFreshUser = prefs.getBool('isFreshUser') ?? true;
  // await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(isLoggedIn: isLoggedIn, isFreshUser: isFreshUser),
    ),
  );
}

class MyApp extends StatelessWidget {
   bool isLoggedIn = false;
   bool isFreshUser = true;
  MyApp({required this.isLoggedIn, required this.isFreshUser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //diable lauch screen
      
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: ScaffoldMessengerKey,
      home: SplashScreen(isLoggedIn: isLoggedIn, isFreshUser: isFreshUser),
      onGenerateRoute: generateRoute,
      

    
    );
  }
}
