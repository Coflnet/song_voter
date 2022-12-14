import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:song_voter/swagger/generated/lib/api.dart';
import 'package:song_voter/utils/route_utils.dart';
import 'package:song_voter/utils/services/google_service.dart';
import 'package:song_voter/utils/theme_utils.dart';
import 'package:song_voter/widgets/error/global_error.dart';
import 'package:song_voter/widgets/login/google_signin/google_signin_controller.dart';
import 'package:song_voter/widgets/home/home_view.dart';
import 'package:song_voter/widgets/home/home_controller.dart';
import 'package:song_voter/widgets/login/google_signin/google_signin_view.dart';
import 'package:song_voter/widgets/login/guest_login/guest_login_view.dart';
import 'package:song_voter/widgets/login/guest_login/warning/guest_login_warning_view.dart';
import 'package:song_voter/widgets/login/login_view.dart';
import 'package:song_voter/widgets/party/create/party_create_controller.dart';
import 'package:song_voter/widgets/party/create/party_create_view.dart';
import 'package:song_voter/widgets/party/detail/party_detail_view.dart';
import 'package:song_voter/widgets/party/list/party_list_controller.dart';
import 'package:song_voter/widgets/party/list/party_list_view.dart';
import 'package:song_voter/widgets/party/party_overview_view.dart';
import 'package:song_voter/widgets/settings/settings_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:song_voter/widgets/youtube_player/youtube_player_controller.dart';
import 'firebase_options.dart';

void main() async {
  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final googleSignIn = GoogleService.getGoogleSignIn();

  void onInit() {
    final apiInstance = AuthApiControllerImplApi(
        ApiClient(basePath: "https://songvoter.party"));

    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      debugPrint(account.toString());
      debugPrint("i am here");
      if (account != null) {
        try {
          final auth = await account.authentication;
          if (auth.idToken == null) {
            debugPrint('No idToken received. Login failed');
            return;
          }
          final token = GoogleService.convertBase64UrlToBase64(auth.idToken!);
          final result = await apiInstance.v1AuthGooglePost(
              coflnetSongVoterModelsAuthToken:
                  CoflnetSongVoterModelsAuthToken(token: token));
          GoogleService.setGoogleToken(result?.token);
          GoogleService.googleAccount = account;
        } catch (e) {
          debugPrint(
              'Exception when calling AuthApiControllerImplApi->v1AuthGooglePost: $e\n');
        }
      }
    });
    googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    String route = "/";
    GoogleSignInAccount? user = GoogleService.googleAccount;

    if (user != null) {
      route = "/home";
    } else {
      route = "/login";
    }

    return GetMaterialApp(
      title: 'SongVoter',
      theme: ThemeUtils.lightTheme,
      initialRoute: route,
      onInit: onInit,
      getPages: [
        GetPage(
            name: Routes.home,
            page: () => HomeView(),
            transition: Transition.fadeIn,
            binding: BindingsBuilder(() => {Get.put(HomeController())})),
        GetPage(
            name: Routes.error,
            page: () => GlobalErrorView(),
            transition: Transition.fadeIn),
        GetPage(
            name: Routes.login,
            page: () => LoginView(),
            transition: Transition.fadeIn),
        GetPage(
            name: Routes.googleLogin,
            page: () => GoogleSigninView(),
            binding: BindingsBuilder(() => {Get.put(GoogleSigninController())}),
            transition: Transition.fadeIn),
        GetPage(
            name: Routes.guestLogin,
            page: () => GuestLoginView(),
            transition: Transition.fadeIn),
        GetPage(
            name: Routes.guestLoginWarning,
            page: () => GuestLoginWarningView(),
            transition: Transition.fadeIn),
        GetPage(
            name: Routes.settings,
            page: () => SettingsView(),
            binding:
                BindingsBuilder(() => {Get.put(YoutubePlayerGetController())}),
            transition: Transition.fadeIn),
        GetPage(
            name: Routes.party,
            page: () => PartyOverviewView(),
            transition: Transition.fadeIn),
        GetPage(
            name: Routes.partyCreate,
            page: () => PartyCreateView(),
            binding: BindingsBuilder(() => {Get.put(PartyCreateController())}),
            transition: Transition.fadeIn),
        GetPage(
            name: Routes.partyDetail,
            page: () => PartyDetailView(),
            transition: Transition.fadeIn),
        GetPage(
            name: Routes.partyList,
            page: () => PartyListView(),
            binding: BindingsBuilder(() => {Get.put(PartyListController())}),
            transition: Transition.fadeIn)
      ],
    );
  }
}
