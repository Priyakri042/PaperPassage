import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {

  ThemeData? currentTheme;
  Color? containerColor;
  Color? cardColor;

  setLightMode() {
    cardColor = Color.fromARGB(255, 247, 238, 201);
    containerColor = Color.fromARGB(255, 247, 238, 201);
    currentTheme = ThemeData(
      scaffoldBackgroundColor:   Colors.white, // LightMode
      
      textTheme:
      TextTheme(
        bodyMedium: TextStyle(color: Color.fromARGB(255, 48, 40, 45),),
        bodySmall: TextStyle(color: Color.fromARGB(255, 48, 40, 45),),
      ),
      brightness: Brightness.light, // LightMode
       // more attributes
       
    );
    notifyListeners();
  }

  setDarkmode() {
    cardColor = Color.fromARGB(255, 48, 40, 45);
    containerColor = Color.fromARGB(255, 48, 40, 45);
    currentTheme = ThemeData(
      brightness: Brightness.dark, // DarkMode
      
      //container colour background should be black
      scaffoldBackgroundColor:  Color.fromARGB(255, 48, 40, 45),
      
      //text colour should be white
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
      ),
    );
    notifyListeners();
  }
}