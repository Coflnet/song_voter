import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:song_voter/models/party.dart';
import 'package:song_voter/widgets/base/base.dart';

class PartyDetailView extends StatelessWidget {
  final Party party = Get.arguments["party"];

  @override
  Widget build(BuildContext context) {
    return Base(
      showNavbar: true,
      navbarIndex: 1,
      child: Text(party.name),
    );
  }
}
