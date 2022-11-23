import 'package:get/get.dart';
import 'package:song_voter/utils/api/party_api.dart';

class PartyCreateController extends GetxController {
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
