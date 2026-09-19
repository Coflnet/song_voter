import 'dart:async';

import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as youtube;

import '../api.dart';
import '../models.dart';
import 'playback.dart';

class YoutubePlayback extends PlaybackAdapter {
  YoutubePlayback() {
    _subscription = controller.listen((value) {
      final id = value.metaData.videoId;
      if (value.hasError) {
        _events.add(
          PlaybackEvent(
            id,
            error: 'YouTube cannot play this video here. Retry or skip it.',
          ),
        );
      } else if (value.playerState == youtube.PlayerState.ended) {
        _events.add(PlaybackEvent(id, ended: true));
      }
    });
  }
  final controller = youtube.YoutubePlayerController(
    params: const youtube.YoutubePlayerParams(
      showFullscreenButton: false,
      enableKeyboard: false,
      playsInline: true,
      origin: 'https://songvoter.party',
    ),
  );
  final _events = StreamController<PlaybackEvent>.broadcast();
  late final StreamSubscription<youtube.YoutubePlayerValue> _subscription;
  @override
  String get platform => 'youtube';
  @override
  Stream<PlaybackEvent> get events => _events.stream;
  @override
  Future<void> connect() async {}
  @override
  Future<void> play(SongSource source) =>
      controller.loadVideoById(videoId: source.id);
  @override
  Future<void> pause() => controller.pauseVideo();
  @override
  Future<void> resume() => controller.playVideo();
  @override
  Future<void> stop() => controller.stopVideo();
  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await controller.close();
    await _events.close();
  }
}

class SpotifyPlayback extends PlaybackAdapter {
  SpotifyPlayback(this.api);
  final SongVoterApi api;
  final _events = StreamController<PlaybackEvent>.broadcast();
  StreamSubscription<PlayerState>? _subscription;
  String? _expected;
  bool _seenTrack = false;
  @override
  String get platform => 'spotify';
  @override
  Stream<PlaybackEvent> get events => _events.stream;
  @override
  Future<void> connect() async {
    if (_subscription != null) return;
    await authorize(api);
    _subscription = SpotifySdk.subscribePlayerState().listen(
      (state) {
        final expected = _expected;
        if (expected == null) return;
        final matches =
            state.track?.uri == 'spotify:track:$expected' ||
            state.track?.linkedFromUri == 'spotify:track:$expected';
        if (matches && !state.isPaused) _seenTrack = true;
        // App Remote reports completion by changing tracks, or pausing at the end.
        // This uses actual SDK state, so pausing/seeking does not advance a timer.
        final ended =
            _seenTrack &&
            (!matches ||
                (state.isPaused &&
                    state.track != null &&
                    state.playbackPosition >= state.track!.duration - 250));
        if (ended) {
          _expected = null;
          _events.add(PlaybackEvent(expected, ended: true));
        }
      },
      onError: (Object _) {
        if (_expected != null) {
          _events.add(
            PlaybackEvent(
              _expected!,
              error: 'Spotify disconnected. Reconnect and retry this song.',
            ),
          );
        }
        unawaited(_subscription?.cancel());
        _subscription = null;
      },
    );
  }

  static Future<void> authorize(SongVoterApi api) async {
    final config =
        await api.request('GET', '/api/config') as Map<String, dynamic>;
    final clientId = config['spotifyClientId'] as String? ?? '';
    if (clientId.isEmpty) {
      throw ApiError(
        'Spotify is not connected to SongVoter yet. You can host with YouTube.',
      );
    }
    if (!await SpotifySdk.connectToSpotifyRemote(
      clientId: clientId,
      redirectUrl: 'com.coflnet.songvoter://spotify-callback',
    )) {
      throw ApiError('Open Spotify on this device, then try connecting again.');
    }
    await SpotifySdk.pause();
  }

  @override
  Future<void> play(SongSource source) async {
    _expected = source.id;
    _seenTrack = false;
    await SpotifySdk.play(spotifyUri: 'spotify:track:${source.id}');
  }

  @override
  Future<void> pause() => SpotifySdk.pause();
  @override
  Future<void> resume() => SpotifySdk.resume();
  @override
  Future<void> stop() async {
    _expected = null;
    if (_subscription != null) await SpotifySdk.pause();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _subscription?.cancel();
    if (_subscription != null) await SpotifySdk.disconnect();
    await _events.close();
  }
}
