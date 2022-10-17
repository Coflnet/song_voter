import 'package:flutter/material.dart';
import 'package:song_voter/widgets/base/base.dart';
import 'package:song_voter/widgets/login/google_signin/google_signin_view.dart';

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
