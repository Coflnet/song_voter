import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:song_voter/utils/route_utils.dart';
import 'package:song_voter/utils/services/user_service.dart';

class HomeController extends GetxController {
  final user = Rx<GoogleSignInAccount?>(null);

  @override
  void onInit() async {
    loadUsername();
    super.onInit();
  }

  updateUser(GoogleSignInAccount? user) {
    this.user(user);
  }

  void loadUsername() {
    GoogleSignInAccount? user = UserService.getUser();
    updateUser(user);
  }

  void onLogout(BuildContext context) {
    UserService.removeUser();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Logged out"),
      backgroundColor: Theme.of(context).primaryColor,
    ));
    Get.toNamed(Routes.login);
  }
}
