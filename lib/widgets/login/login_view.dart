import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:song_voter/utils/route_utils.dart';
import 'package:song_voter/widgets/base/base.dart';
import 'package:song_voter/widgets/login/guest_login/guest_login_view.dart';

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);

  void _handleGuestSignIn() {
    Get.toNamed(Routes.guestLoginWarning);
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
                  bottom: MediaQuery.of(context).size.height * 0.2),
              child: Center(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("SongVoter",
                        style: Theme.of(context).textTheme.headline1),
                  )
                ]),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text("Placeholder...")),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text("Placeholder...")),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.33,
                    child: Divider(
                      color: Colors.black,
                      thickness: 3,
                      height: 3,
                      indent: 3,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.33,
                    child: Center(
                      child: Text("or"),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.33,
                    child: Divider(
                      color: Colors.black,
                      thickness: 3,
                      height: 3,
                      indent: 3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.5,
              child: TextButton(
                onPressed: _handleGuestSignIn,
                child: Text(
                  "Login as Guest",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            )
          ],
        ));
  }
}
