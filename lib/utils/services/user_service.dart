import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:song_voter/utils/services/base_service.dart';

class UserService extends BaseService {
  static const usernameStorageKey = "username";
  static const authcodeStorageKey = "authcode";

  static GoogleSignInAccount? getUser() {
    return GetStorage().read<GoogleSignInAccount>(usernameStorageKey);
  }

  static String? getAuthCode() {
    return GetStorage().read<String>(authcodeStorageKey);
  }

  static Future<void> setUser(
      GoogleSignInAccount user, String? authCode) async {
    GetStorage().write(authcodeStorageKey, authCode);
    GetStorage().write(usernameStorageKey, user);
  }

  static void removeUser() {
    GetStorage().remove(usernameStorageKey);
    GetStorage().remove(authcodeStorageKey);
  }
}
