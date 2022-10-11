import 'package:flutter/material.dart';
import 'package:song_voter/app/data/models/party.dart';
import 'package:song_voter/global_widgets/base.dart';

class PartyDetailWidget extends StatelessWidget {
  const PartyDetailWidget({Key? key, required Party this.party})
      : super(key: key);

  final Party party;

  @override
  Widget build(BuildContext context) {
    return Base(
      showNavbar: true,
      navbarIndex: 1,
      child: Text(party.name),
    );
  }
}
