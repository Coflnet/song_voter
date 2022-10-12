import 'package:get_storage/get_storage.dart';
import 'package:song_voter/app/data/services/base_service.dart';

class UserService extends BaseService {
  String? getUsername() {
    return GetStorage().read<String>("username");
  }

  Future<void> setUsername(String username) async {
    GetStorage().write("username", username);
  }

  void removeUsername() {
    GetStorage().remove("username");
  }
}
