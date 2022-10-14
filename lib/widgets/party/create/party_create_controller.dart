import 'package:get/get.dart';
import 'package:song_voter/utils/services/user_service.dart';

class PartyCreateController extends GetxController {
  final userService = UserService();
  final isPrivate = false.obs;

  void setIsPrivate(bool private) {
    isPrivate(private);
  }
}
