import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:openapi/api.dart';

class YoutubePlayerGetController extends GetxController {
  final videoSearchText = ''.obs;
  final api_instance = SongApiControllerImplApi();

  void onSearch() async {
    try {
      final result = await api_instance.v1SongsSearchGet(videoSearchText.value);
    } catch (e) {
      debugPrint(
          'Exception when calling SongApiControllerImplApi->v1SongsSearchGet: $e\n');
    }
  }
}
