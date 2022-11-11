import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

GoogleSignIn googleSignIn = GoogleSignIn(
  serverClientId:
      "450316132885-2a1k6vmlno1tl530c7he4gicgil2j37g.apps.googleusercontent.com",
  scopes: <String>[
    'email',
  ],
);

class GoogleSigninController extends GetxController {
  final currentUser = Rx<GoogleSignInAccount?>(null);
  final contactText = ''.obs;

  @override
  void onInit() async {
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      currentUser(account);
    });
    googleSignIn.signInSilently();
    super.onInit();
  }

  Future<void> handleSignOut() => googleSignIn.disconnect();

  Future<void> handleSignIn() async {
    try {
      await googleSignIn.signIn();
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
