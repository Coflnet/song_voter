import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:openapi/api.dart';
import 'package:song_voter/utils/services/google_service.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId:
        "450316132885-2a1k6vmlno1tl530c7he4gicgil2j37g.apps.googleusercontent.com",
    scopes: <String>[
      'email',
    ]);

class GoogleSigninController extends GetxController {
  var currentUser = Rx<GoogleSignInAccount?>(null);
  final googleSignIn = GoogleService.getGoogleSignIn();
  final contactText = ''.obs;
  final apiInstance =
      AuthApiControllerImplApi(ApiClient(basePath: "https://songvoter.party"));

  @override
  void onInit() async {
    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      debugPrint("google sign in controller");
      currentUser.value = account;
    });
    googleSignIn.signInSilently();
    super.onInit();
  }

  void handleSignOut() async {
    await googleSignIn.disconnect();
    currentUser.value = null;
  }

  Future<void> handleSignIn() async {
    try {
      await googleSignIn.signIn();
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
