import 'package:flutter/material.dart';
import 'package:song_voter/widgets/base.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Base(
      showNavbar: true,
      navbarIndex: 2,
      child: Center(
        child: Text("settings"),
      ),
    );
  }
}
