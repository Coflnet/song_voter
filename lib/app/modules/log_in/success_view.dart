import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/app/modules/home/home.dart';
import 'package:song_voter/global_widgets/base.dart';

class LoginSuccessView extends StatelessWidget {
  void _handleContinue() {
    Get.to(HomeWidget());
  }

  @override
  Widget build(BuildContext context) {
    return Base(
      showNavbar: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.2,
              bottom: MediaQuery.of(context).size.height * 0.1,
            ),
            child: Center(
              child: Icon(
                Icons.done_outline,
                size: MediaQuery.of(context).size.height * 0.2,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.2,
            ),
            child: Center(
              child: Text(
                "Success",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.033,
            ),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.075,
                child: TextButton(
                  child: Text(
                    "Continue",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  onPressed: _handleContinue,
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              child: Text(
                "Thanks for joining Song Voter",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
