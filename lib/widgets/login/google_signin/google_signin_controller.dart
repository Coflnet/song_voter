import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:openapi/api.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        "450316132885-2a1k6vmlno1tl530c7he4gicgil2j37g.apps.googleusercontent.com",
    scopes: <String>[
      'email',
    ]);

class GoogleSigninController extends GetxController {
  final currentUser = Rx<GoogleSignInAccount?>(null);
  final contactText = ''.obs;
  final api_instance =
      AuthApiControllerImplApi(ApiClient(basePath: "https://songvoter.party"));

  @override
  void onInit() async {
    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      currentUser(account);
      try {
        final auth = await account?.authentication;
        debugPrint(auth?.idToken);
        final result = await api_instance.v1AuthGooglePost(
            coflnetSongVoterModelsAuthToken:
                CoflnetSongVoterModelsAuthToken(token: auth?.idToken));
      } catch (e) {
        debugPrint(
            'Exception when calling AuthApiControllerImplApi->v1AuthGooglePost: $e\n');
      }
    });
    googleSignIn.signInSilently();
    super.onInit();
  }

  Future<void> handleSignOut() {
    currentUser(null);
    return googleSignIn.disconnect();
  }

  Future<void> handleSignIn() async {
    try {
      await googleSignIn.signIn();
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
