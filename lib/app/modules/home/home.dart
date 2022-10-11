import 'package:flutter/material.dart';
import 'package:song_voter/global_widgets/base.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Base(
        showNavbar: true,
        navbarIndex: 0,
        child: Center(
          child: Text("Home Screen"),
        ));
  }
}
