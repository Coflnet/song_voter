import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:song_voter/api.dart';
import 'package:song_voter/models.dart';
import 'package:song_voter/playback/native_adapters.dart';
import 'package:song_voter/playback/playback.dart';

class ConfigApi extends SongVoterApi {
  @override
  Future<dynamic> request(String method, String path, [dynamic body]) async => {
    'spotifyClientId': 'test-client',
  };
}

class SpotifyPlatform extends SpotifySdkPlatform {
  final states = StreamController<PlayerState>.broadcast();
  bool installed = true;
  String? played;
  @override
  Future<bool> isSpotifyInstalled() async => installed;
  @override
  Future<bool> connectToSpotifyRemote({
    required String clientId,
    required String redirectUrl,
    String spotifyUri = '',
    bool asRadio = false,
    String? scope,
    String playerName = 'Spotify SDK',
    String? accessToken,
  }) async => true;
  @override
  Stream<PlayerState> subscribePlayerState() => states.stream;
  @override
  Future<void> play({required String spotifyUri, bool asRadio = false}) async {
    played = spotifyUri;
  }

  @override
  Future<void> pause() async {}
  @override
  Future<bool> disconnect() async => true;
}

PlayerState state(String? id, {bool paused = false, int position = 1000}) =>
    PlayerState.fromJson({
      'track': id == null
          ? null
          : {
              'album': {'name': 'Album', 'uri': ''},
              'artist': {'name': 'Artist', 'uri': ''},
              'artists': [],
              'duration_ms': 180000,
              'image_id': {'raw': ''},
              'name': 'Song',
              'uri': 'spotify:track:$id',
            },
      'playback_speed': 1.0,
      'playback_position': position,
      'is_paused': paused,
      'playback_options': {'repeat': 0, 'shuffle': false},
      'playback_restrictions': {
        for (final key in [
          'can_skip_next',
          'can_skip_prev',
          'can_repeat_track',
          'can_repeat_context',
          'can_toggle_shuffle',
          'can_seek',
        ])
          key: true,
      },
    });

void main() {
  late SpotifyPlatform platform;
  late SpotifySdkPlatform original;
  late ConfigApi api;
  setUp(() {
    original = SpotifySdkPlatform.instance;
    platform = SpotifyPlatform();
    SpotifySdkPlatform.instance = platform;
    api = ConfigApi();
  });
  tearDown(() async {
    SpotifySdkPlatform.instance = original;
    await platform.states.close();
    api.dispose();
  });
  test('Spotify pauses and missing SDK state do not skip a song; track completion emits once', () async {
    final adapter = SpotifyPlayback(api);
    final events = <PlaybackEvent>[];
    final subscription = adapter.events.listen(events.add);
    await adapter.connect();
    await adapter.play(
      SongSource.fromJson({'platform': 'spotify', 'externalId': 'first'}),
    );
    expect(platform.played, 'spotify:track:first');
    platform.states.add(state('first'));
    platform.states.add(state('first', paused: true));
    platform.states.add(state(null));
    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty);
    platform.states.add(state('first'));
    platform.states.add(state('next'));
    platform.states.add(state('next'));
    await Future<void>.delayed(Duration.zero);
    expect(events, hasLength(1));
    expect(events.single.sourceId, 'first');
    expect(events.single.ended, isTrue);
    await subscription.cancel();
    await adapter.dispose();
  });
  test('a missing Spotify app gives an actionable setup message', () async {
    platform.installed = false;
    await expectLater(
      SpotifyPlayback.authorize(api),
      throwsA(
        isA<ApiError>().having(
          (e) => e.message,
          'message',
          contains('Install Spotify'),
        ),
      ),
    );
  });
}
