import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:song_voter/utils/services/user_service.dart';
import 'package:song_voter/widgets/log_in/login_view.dart';

class HomeController extends GetxController {
  final userService = UserService();
  final username = "".obs;

  @override
  void onInit() async {
    loadUsername();
    super.onInit();
  }

  updateUsername(String username) {
    this.username(username);
  }

  void loadUsername() {
    String username = userService.getUsername() ?? "";
    debugPrint("loaded username $username");
    updateUsername(username);
  }

  void onLogout(BuildContext context) {
    userService.removeUsername();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Logged out"),
      backgroundColor: Theme.of(context).primaryColor,
    ));
    Get.to(() => LoginView(headline: "SongVoter"));
    Get.delete<HomeController>();
  }
}
