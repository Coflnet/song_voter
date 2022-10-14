import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeUtils {
  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    backgroundColor: const Color.fromARGB(255, 0, 0, 21),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headline1: const TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 0x72, 0x73, 0x94),
      ),
      bodyText1: const TextStyle(
        fontSize: 16,
        color: Color.fromARGB(0xff, 0x72, 0x73, 0x94),
      ),
      bodyText2: const TextStyle(
        fontSize: 20,
        color: Color.fromARGB(0xff, 0x72, 0x73, 0x94),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.deepOrangeAccent,
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    backgroundColor: Colors.white,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headline1: const TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.bold,
      ),
      headline2: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
      headline4: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
      headline5: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headline6: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
      bodyText1: const TextStyle(
        fontSize: 16,
      ),
      bodyText2: const TextStyle(
        fontSize: 20,
      ),
    ),
  );
}
