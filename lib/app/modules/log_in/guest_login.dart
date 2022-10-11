import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/app/modules/log_in/guest_login_warning_view.dart';

class GuestLoginWidget extends StatelessWidget {
  String previousTitle;

  GuestLoginWidget({Key? key, required this.previousTitle}) : super(key: key);

  void _handleSignIn() {
    Get.to(GuestLoginWarningWidget(
      previousTitle: previousTitle,
    ));
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width * 0.5,
      child: TextButton(
        onPressed: _handleSignIn,
        child: Text(
          "Login as Guest",
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
    );
  }
}
