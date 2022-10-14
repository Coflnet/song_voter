import 'package:get_storage/get_storage.dart';
import 'package:song_voter/models/user.dart';
import 'package:song_voter/utils/services/base_service.dart';

class UserService extends BaseService {
  final usernameStorageKey = "username";

  User? getUser() {
    String? username = GetStorage().read<String>(usernameStorageKey);
    return username == null ? null : User(username: username);
  }

  Future<void> setUser(User user) async {
    GetStorage().write(usernameStorageKey, user.username);
  }

  void removeUsername() {
    GetStorage().remove(usernameStorageKey);
  }
}
