import 'package:get/get.dart';
import 'package:song_voter/models/party.dart';

class PartyListController extends GetxController {
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
