import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

GoogleSignIn googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class GoogleSigninController extends GetxController {
  final currentUser = Rx<GoogleSignInAccount?>(null);
  final contactText = ''.obs;

  @override
  void onInit() async {
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      currentUser(account);
      if (account != null) {
        handleGetContact(account);
      }
    });
    googleSignIn.signInSilently();
    super.onInit();
  }

  Future<void> handleGetContact(GoogleSignInAccount user) async {
    contactText('Loading contact info...');
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      contactText('People API gave a ${response.statusCode} '
          'response. Check logs for details.');
      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = pickFirstNamedContact(data);
    if (namedContact != null) {
      contactText('I see you know $namedContact!');
    } else {
      contactText('No contacts to display.');
    }
  }

  String? pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  Future<void> handleSignOut() => googleSignIn.disconnect();

  Future<void> handleSignIn() async {
    try {
      await googleSignIn.signIn();
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
