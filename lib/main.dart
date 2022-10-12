import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:song_voter/app/data/models/user.dart';
import 'package:song_voter/app/modules/home/home.dart';
import 'package:song_voter/app/modules/log_in/login_view.dart';
import 'package:song_voter/global_widgets/global_error.dart';
import 'package:get/instance_manager.dart' as instance_manager;

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget? homeWidget;
    User? user = loadUser();

    if (user != null) {
      homeWidget = HomeWidget();
    } else {
      homeWidget = LoginWidget(
        headline: "Song Voter",
      );
    }

    return GetMaterialApp(
      title: 'Song Voter',
      theme: lightTheme(),
      home: homeWidget,
    );
  }

  User? loadUser() {
    return null;
  }

  ThemeData darkTheme() {
    return ThemeData(
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
  }

  ThemeData lightTheme() {
    return ThemeData(
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
}
