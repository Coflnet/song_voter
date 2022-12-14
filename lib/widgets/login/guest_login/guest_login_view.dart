import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:song_voter/utils/route_utils.dart';
import 'package:song_voter/widgets/base/base.dart';

class GuestLoginView extends StatelessWidget {
  String _username = "";

  void _onContinuePress(BuildContext context) async {
    if (_username.isNotEmpty) {
      //await UserService.setUser(null, "test");
      Get.offAllNamed(Routes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a username"),
        backgroundColor: Theme.of(context).errorColor,
      ));
    }
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
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Center(
                child: Icon(
                  Icons.done_outline,
                  size: MediaQuery.of(context).size.height * 0.2,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Username'),
                  onChanged: (value) => {_username = value},
                ),
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
                    onPressed: () {
                      _onContinuePress(context);
                    },
                    child: Text(
                        style: Theme.of(context).textTheme.headline5,
                        "Continue")),
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
