import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:song_voter/api.dart';
import 'package:song_voter/party_state.dart';

Map<String, dynamic> snapshot(int version) => {
  'id': 'party',
  'name': 'Kitchen',
  'ownerId': 'host',
  'version': version,
  'members': 1,
  'platforms': ['youtube'],
  'queue': [],
};

class DelayedApi extends SongVoterApi {
  final poll = Completer<Map<String, dynamic>>();
  final next = Completer<Map<String, dynamic>>();
  @override
  Future<dynamic> request(String method, String path, [dynamic body]) async {
    if (method == 'GET') return poll.future;
    if (path.endsWith('/next')) return next.future;
    return null;
  }
}

void main() {
  test('an old poll cannot overwrite a completed playback advance', () async {
    final api = DelayedApi();
    final state = PartyState(api);
    final refresh = state.refresh();
    final advance = state.advance(0);
    api.next.complete(snapshot(1));
    await advance;
    api.poll.complete(snapshot(0));
    await refresh;
    expect(state.party!.version, 1);
    state.dispose();
  });

  test(
    'a delayed playback response cannot restore a party after leaving',
    () async {
      final api = DelayedApi();
      final state = PartyState(api);
      final advance = state.advance(0);
      final rejected = expectLater(advance, throwsA(isA<ApiError>()));
      await state.leave();
      api.next.complete(snapshot(1));
      await rejected;
      expect(state.party, isNull);
      state.dispose();
    },
  );
}
