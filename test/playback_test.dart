import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:song_voter/api.dart';
import 'package:song_voter/models.dart';
import 'package:song_voter/party_state.dart';
import 'package:song_voter/playback/playback.dart';

Party party(int version, String platform) => Party.fromJson({
  'id': 'party',
  'name': 'Kitchen',
  'ownerId': 'host',
  'version': version,
  'members': 2,
  'platforms': ['youtube', 'spotify'],
  'queue': [],
  'currentSong': {
    'id': 'song$version',
    'title': 'Song $version',
    'occurences': [
      {'platform': platform, 'externalId': 'source$version'},
    ],
  },
});

class TestState extends PartyState {
  TestState() : super(SongVoterApi()) {
    api.session = {'userId': 'host'};
    this.party = party(0, 'youtube');
  }
  int calls = 0;
  @override
  Future<Party> advance(int version) async {
    calls++;
    await Future<void>.delayed(Duration.zero);
    if (version != this.party!.version) throw ApiError('Stale playback', 409);
    return this.party = party(
      version + 1,
      version == 0 ? 'youtube' : 'spotify',
    );
  }

  @override
  Future<void> refresh() async {}
}

class FakePlayer extends PlaybackAdapter {
  FakePlayer(this.platform);
  @override
  final String platform;
  final controller = StreamController<PlaybackEvent>.broadcast();
  bool playing = false, fail = false;
  String? source;
  @override
  Stream<PlaybackEvent> get events => controller.stream;
  @override
  Future<void> connect() async {}
  @override
  Future<void> play(SongSource value) async {
    if (fail) throw Exception('Disconnected');
    playing = true;
    source = value.id;
  }

  @override
  Future<void> stop() async {
    playing = false;
  }

  @override
  Future<void> pause() => stop();
  @override
  Future<void> resume() async {
    playing = true;
  }

  @override
  Future<void> dispose() => controller.close();
}

void main() {
  test('real end events advance once and stop the previous provider before playing the next', () async {
    final state = TestState(),
        youtube = FakePlayer('youtube'),
        spotify = FakePlayer('spotify');
    final player = HostPlayback(state, [youtube, spotify]);
    await player.next();
    expect(youtube.playing, isTrue);
    youtube.controller.add(const PlaybackEvent('source1', ended: true));
    youtube.controller.add(const PlaybackEvent('source1', ended: true));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(state.calls, 2);
    expect(youtube.playing, isFalse);
    expect(spotify.playing, isTrue);
    await player.togglePause();
    expect(spotify.playing, isFalse);
    expect(state.calls, 2);
    player.dispose();
    state.dispose();
  });
  test('failed playback retries the same song without consuming the next queue entry', () async {
    final state = TestState(), youtube = FakePlayer('youtube')..fail = true;
    final player = HostPlayback(state, [youtube]);
    await player.next();
    expect(player.error, isNotNull);
    expect(state.calls, 1);
    youtube.fail = false;
    await player.retry();
    expect(state.calls, 1);
    expect(youtube.source, 'source1');
    expect(player.error, isNull);
    player.dispose();
    state.dispose();
  });
}
