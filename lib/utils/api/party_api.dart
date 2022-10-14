import 'dart:convert';
import 'package:song_voter/models/party.dart';
import 'package:song_voter/utils/api/api_utils.dart';
import 'package:http/http.dart' as http;

class PartyAPI extends ApiUtils {
  static Future<List<Party>> getParties() async {
    final response = await http.get(
      ApiUtils.buildUri("/partys"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (ApiUtils.isReponseOk(response.statusCode)) {
      return ApiUtils.parseList<Party>(response.body, Party.fromJson);
    } else {
      return ApiUtils.getFutureError(response);
    }
  }

  static Future<Party> createParty() async {
    final response = await http.post(
      ApiUtils.buildUri("/partys"),
      headers: ApiUtils.getDefaultHeaders(),
    );
    if (ApiUtils.isReponseOk(response.statusCode)) {
      return Party.fromJson(jsonDecode(response.body));
    } else {
      return ApiUtils.getFutureError(response);
    }
  }
}
