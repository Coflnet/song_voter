import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

GoogleSignIn googleSignIn = GoogleSignIn(
  serverClientId:
      "1092901711600-m6mi9761ncl8eu9vs010eju8cnjmah0s.apps.googleusercontent.com",
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
