import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {

  ThemeData? currentTheme;

  setLightMode() {
    currentTheme = ThemeData(
      brightness: Brightness.light, // LightMode
       // more attributes
       
    );
    notifyListeners();
  }

  setDarkmode() {
    currentTheme = ThemeData(
      brightness: Brightness.dark, // DarkMode
      
      //container colour background should be black
      scaffoldBackgroundColor: Colors.transparent,
      //text colour should be white
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
      ),
    );
    notifyListeners();
  }
}
