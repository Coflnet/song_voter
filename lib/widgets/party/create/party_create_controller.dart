import 'package:get/get.dart';
import 'package:song_voter/utils/api/party_api.dart';
import 'package:song_voter/utils/services/user_service.dart';

class PartyCreateController extends GetxController {
  final userService = UserService();
  final api_instance = PartyAPI();

  void onPartyCreate() {
    try {
      //final result = api_instance.createParty();
      //print(result);
    } catch (e) {
      print('Exception when calling PartyApi->createParty: $e\n');
    }
  }
}
