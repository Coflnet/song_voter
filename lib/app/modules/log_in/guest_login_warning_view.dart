import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/app/modules/log_in/login_view.dart';
import 'package:song_voter/app/modules/log_in/success_view.dart';
import 'package:song_voter/global_widgets/base.dart';

class GuestLoginWarningWidget extends StatelessWidget {
  String previousTitle;

  GuestLoginWarningWidget({Key? key, required this.previousTitle})
      : super(key: key);

  void _handleContinue() {
    Get.to(LoginSuccessView());
  }

  void _handleBack() {
    Get.to(LoginWidget(
      headline: previousTitle,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Base(
      showNavbar: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(
              size.width * 0.05,
            ).add(
              EdgeInsets.only(
                top: size.height * 0.1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.warning_amber_outlined,
                size: size.height * 0.33,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.025,
              bottom: size.height * 0.025,
            ),
            child: Text(
              "Are you sure?",
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          Text(
            "You won't be able to use all features",
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.1,
            ),
            child: SizedBox(
              height: size.height * 0.1,
              width: size.width * 0.8,
              child: TextButton(
                onPressed: _handleContinue,
                child: Text(
                  "Yes, I am",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
          ),
          SizedBox(
            height: size.height * 0.1,
            width: size.width * 0.8,
            child: TextButton(
              onPressed: _handleBack,
              child: Text(
                "No, back please",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
