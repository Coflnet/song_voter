import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/app/modules/party/party_create.dart';
import 'package:song_voter/app/modules/party/party_list.dart';
import 'package:song_voter/global_widgets/base.dart';

class PartyOverviewWidget extends StatelessWidget {
  void _handleCreate() {
    Get.to(PartyCreateWidget());
  }

  void _handleJoin() {
    Get.to(PartyListWidget());
  }

  @override
  Widget build(BuildContext context) {
    return Base(
      showNavbar: true,
      navbarIndex: 1,
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
              ),
              child: Icon(
                Icons.celebration_outlined,
                size: MediaQuery.of(context).size.width * 0.66,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.15,
              ),
              child: Text(
                "You are not in party",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
              ),
              child: TextButton(
                child: Text(
                  "Create one",
                  style: Theme.of(context).textTheme.headline5,
                ),
                onPressed: _handleCreate,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
              ),
              child: TextButton(
                child: Text(
                  "Join one",
                  style: Theme.of(context).textTheme.headline5,
                ),
                onPressed: _handleJoin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
