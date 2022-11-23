import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:song_voter/utils/services/base_service.dart';

class GoogleService extends BaseService {
  static const googleTokenStorageKey = "googleToken";
  static GoogleSignInAccount? googleAccount;

  static String? getAuthCode() {
    return GetStorage().read<String>(googleTokenStorageKey);
  }

  static Future<void> setGoogleToken(String? token) async {
    GetStorage().write(googleTokenStorageKey, token);
  }

  static void removeGoogleToken() {
    GetStorage().remove(googleTokenStorageKey);
  }

  static GoogleSignIn getGoogleSignIn() {
    return GoogleSignIn(
        serverClientId:
            "450316132885-2a1k6vmlno1tl530c7he4gicgil2j37g.apps.googleusercontent.com",
        scopes: <String>[
          'email',
        ]);
  }

  static String convertBase64UrlToBase64(String base64Url) {
    List<String> splits =
        base64Url.replaceAll("-", "+").replaceAll("_", "/").split(".");

    splits.forEach((split) {
      while (split.length % 4 != 0) {
        split = "$split=";
      }
    });

    return splits.join(".");
  }
}
