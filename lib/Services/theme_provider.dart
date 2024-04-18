import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Future<void> saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> getThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ??
        false; // Returns 'false' if no value is found
  }

  ThemeProvider() {
    getThemePreference().then((isDarkMode) {
      if (isDarkMode) {
        setDarkmode();
      } else {
        setLightMode();
      }
    });
  }

  

  ThemeData? currentTheme;
  Color? containerColor;
  Color? cardColor;


  setLightMode() {
    saveThemePreference(false);
    cardColor = Color.fromARGB(255, 247, 238, 201);
    containerColor = Color.fromARGB(255, 247, 238, 201);
    currentTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white, // LightMode

      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: Color.fromARGB(255, 48, 40, 45),
        ),
        bodySmall: TextStyle(
          color: Color.fromARGB(255, 48, 40, 45),
        ),
      ),
      brightness: Brightness.light, // LightMode

      // more attributes
    );
    notifyListeners();
  }

  setDarkmode() {
    saveThemePreference(true);
    cardColor = Color.fromARGB(255, 48, 40, 45);
    containerColor = Color.fromARGB(255, 48, 40, 45);
    currentTheme = ThemeData(
      brightness: Brightness.dark, // DarkMode

      //container colour background should be black
      scaffoldBackgroundColor: Color.fromARGB(255, 48, 40, 45),

      //text colour should be white
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
      ),
    );
    notifyListeners();
  }
}
