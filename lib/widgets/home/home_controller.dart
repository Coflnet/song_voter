import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:song_voter/models/user.dart';
import 'package:song_voter/utils/route_utils.dart';
import 'package:song_voter/utils/services/user_service.dart';
import 'package:song_voter/widgets/login/login_view.dart';

class HomeController extends GetxController {
  final userService = UserService();
  final user = Rx<User?>(null);

  @override
  void onInit() async {
    loadUsername();
    super.onInit();
  }

  updateUser(User? user) {
    this.user(user);
  }

  void loadUsername() {
    User? user = userService.getUser();
    updateUser(user);
  }

  void onLogout(BuildContext context) {
    userService.removeUsername();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Logged out"),
      backgroundColor: Theme.of(context).primaryColor,
    ));
    Get.toNamed(Routes.login);
  }
}
