import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/utils/route_utils.dart';
import 'package:song_voter/widgets/base/base.dart';

class PartyOverviewView extends StatelessWidget {
  void _handleCreate() {
    Get.toNamed(Routes.partyCreate);
  }

  void _handleJoin() {
    Get.toNamed(Routes.partyList);
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
                  onPressed: _handleCreate,
                  child: Text(
                    "Create one",
                    style: Theme.of(context).textTheme.headline5,
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
              ),
              child: TextButton(
                onPressed: _handleJoin,
                child: Text(
                  "Join one",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
