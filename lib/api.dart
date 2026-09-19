import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiError implements Exception {
  ApiError(this.message, [this.status = 0]);
  final String message;
  final int status;
  @override
  String toString() => message;
}

// Native runs this in an isolate; yielding also keeps Flutter web responsive.
Future<int> solveProof(Map<String, dynamic> challenge) async {
  final prefix = '${challenge['id']}:${challenge['secret']}:';
  final difficulty = challenge['difficulty'] as int;
  final expires = DateTime.parse(challenge['expiresAt'] as String);
  for (var counter = 0; ; counter++) {
    if (counter % 1024 == 0) {
      if (DateTime.now().isAfter(expires)) {
        throw ApiError('Connecting took too long. Please retry.');
      }
      await Future<void>.delayed(Duration.zero);
    }
    final bytes = sha256.convert(utf8.encode('$prefix$counter')).bytes;
    var valid = true;
    for (var bit = 0; bit < difficulty; bit++) {
      if (bytes[bit ~/ 8] & (128 >> (bit % 8)) != 0) {
        valid = false;
        break;
      }
    }
    if (valid) return counter;
  }
}

class SongVoterApi {
  SongVoterApi({
    String? baseUrl,
    http.Client? client,
    FlutterSecureStorage? storage,
  }) : baseUrl =
           baseUrl ??
           const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
       client = client ?? http.Client(),
       storage = storage ?? const FlutterSecureStorage();
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage storage;
  Map<String, dynamic>? session;
  Future<void>? _connecting;

  String get origin => baseUrl.isNotEmpty
      ? baseUrl
      : kIsWeb
      ? Uri.base.origin
      : 'https://songvoter.party';
  String? get userId => session?['userId'] as String?;

  Future<dynamic> _send(
    String method,
    String path,
    dynamic body, {
    bool authenticated = true,
  }) async {
    final request = http.Request(method, Uri.parse('$origin$path'));
    request.headers['Content-Type'] = 'application/json';
    if (authenticated && session != null) {
      request.headers['Authorization'] = 'Bearer ${session!['token']}';
    }
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(
      await client.send(request).timeout(const Duration(seconds: 20)),
    );
    if (response.statusCode >= 400) {
      var message = response.body;
      if (message.startsWith('{')) {
        final error = jsonDecode(message) as Map<String, dynamic>;
        message =
            error['detail'] as String? ??
            error['title'] as String? ??
            'Please try again.';
      }
      if (response.statusCode == 429) {
        message = 'A little too fast. Give it a moment, then try again.';
      }
      if (message.length > 250 || message.startsWith('<')) {
        message = 'Could not connect to the party. Please retry.';
      }
      throw ApiError(message, response.statusCode);
    }
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }

  Future<void> connect({bool renew = false}) async {
    if (_connecting != null) return _connecting!;
    final future = _authenticate(renew);
    _connecting = future;
    try {
      await future;
    } finally {
      _connecting = null;
    }
  }

  Future<void> _authenticate(bool renew) async {
    if (!renew) {
      final saved = await storage.read(key: 'session');
      if (saved != null) {
        session = jsonDecode(saved) as Map<String, dynamic>;
        if (DateTime.parse(session!['expiresAt'] as String)
            .isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
          return;
        }
      }
    }
    var secret = await storage.read(key: 'deviceSecret');
    if (secret == null) {
      final random = Random.secure();
      secret = List.generate(
        32,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      await storage.write(key: 'deviceSecret', value: secret);
    }
    final challenge = await _send('POST', '/api/auth/challenge', {
      'identityHash': sha256.convert(utf8.encode(secret)).toString(),
    }, authenticated: false) as Map<String, dynamic>;
    final counter = await compute(solveProof, {...challenge, 'secret': secret});
    session = await _send('POST', '/api/auth/anonymous', {
      'challengeId': challenge['id'],
      'secret': secret,
      'counter': counter,
    }, authenticated: false) as Map<String, dynamic>;
    await storage.write(key: 'session', value: jsonEncode(session));
  }

  Future<dynamic> request(String method, String path, [dynamic body]) async {
    if (session == null ||
        DateTime.parse(session!['expiresAt'] as String)
            .isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
      await connect();
    }
    try {
      return await _send(method, path, body);
    } on ApiError catch (error) {
      if (error.status != 401) rethrow;
      await connect(renew: true);
      return _send(method, path, body);
    }
  }

  void dispose() => client.close();
}
