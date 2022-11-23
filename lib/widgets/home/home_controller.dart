import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:song_voter/utils/route_utils.dart';
import 'package:song_voter/utils/services/google_service.dart';

class HomeController extends GetxController {
  final user = Rx<GoogleSignInAccount?>(GoogleService.googleAccount);

  void onLogout(BuildContext context) {
    GoogleService.removeGoogleToken();
    GoogleService.googleAccount = null;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Logged out"),
      backgroundColor: Theme.of(context).primaryColor,
    ));
    Get.toNamed(Routes.login);
  }
}
