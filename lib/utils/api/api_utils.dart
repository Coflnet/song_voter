import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiUtils {
  static const baseUrl = "https://sv.coflnet.com";

  static Uri buildUri(String endpoint) {
    return Uri.parse("$baseUrl$endpoint");
  }

  static bool isReponseOk(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static List<T> parseList<T>(String responseBody, Function fromJson) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<T>((json) => fromJson(json)).toList();
  }

  static Map<String, String> getDefaultHeaders() {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  static getFutureError(Response response) {
    return Future.error(
        HttpException(response.body, uri: response.request?.url));
  }
}
