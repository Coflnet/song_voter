import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:song_voter/app/modules/home/home_controller.dart';
import 'package:song_voter/app/data/services/user_service.dart';
import 'package:song_voter/app/modules/log_in/login_view.dart';
import 'package:song_voter/global_widgets/base.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Base(
        showNavbar: true,
        navbarIndex: 0,
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.2,
              bottom: MediaQuery.of(context).size.height * 0.2,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Center(
                child: Icon(
                  Icons.queue_music_outlined,
                  size: MediaQuery.of(context).size.height * 0.3,
                ),
              ),
            ),
          ),
          Center(
            child: Obx(() => Text("Hello ${controller.username}")),
          ),
          TextButton(
              onPressed: () {
                controller.onLogout(context);
              },
              child: Text("Logout"))
        ]));
  }
}
