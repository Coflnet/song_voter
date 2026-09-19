import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:song_voter/api.dart';
import 'package:song_voter/party_state.dart';

void main() {
  test('background proof matches the server byte-level protocol', () async {
    final challenge = {
      'id': 'challenge',
      'secret': 'a' * 64,
      'difficulty': 16,
      'expiresAt': DateTime.now()
          .toUtc()
          .add(const Duration(minutes: 1))
          .toIso8601String(),
    };
    final counter = await solveProof(challenge);
    final digest = sha256
        .convert(
          utf8.encode('${challenge['id']}:${challenge['secret']}:$counter'),
        )
        .bytes;
    expect(digest.take(2), [0, 0]);
    challenge['expiresAt'] = DateTime.now()
        .toUtc()
        .subtract(const Duration(seconds: 1))
        .toIso8601String();
    await expectLater(solveProof(challenge), throwsA(isA<ApiError>()));
  });
  test('join links use the canonical domain and validate the code', () {
    expect(
      PartyState.inviteCode('https://songvoter.party/join/123456abcdef'),
      '123456abcdef',
    );
    expect(PartyState.inviteCode('123456abcdef'), '123456abcdef');
    expect(
      PartyState.inviteCode('https://evil.test/join/123456abcdef'),
      isNull,
    );
  });
}
