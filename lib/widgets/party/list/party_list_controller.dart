import 'package:get/get.dart';
import 'package:song_voter/models/party.dart';
import 'package:song_voter/utils/services/user_service.dart';

class PartyListController extends GetxController {
  final userService = UserService();
  final parties = <Party>[].obs;

  @override
  void onInit() async {
    loadParties();
    super.onInit();
  }

  void loadParties() {
    parties([]);
  }
}
