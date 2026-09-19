import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api.dart';
import '../models.dart';
import '../party_state.dart';

class PlaybackEvent {
  const PlaybackEvent(this.sourceId, {this.ended = false, this.error});
  final String sourceId;
  final bool ended;
  final String? error;
}

abstract class PlaybackAdapter {
  String get platform;
  Stream<PlaybackEvent> get events;
  Future<void> connect();
  Future<void> play(SongSource source);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
}

class HostPlayback extends ChangeNotifier {
  HostPlayback(this.state, this.adapters) {
    for (final adapter in adapters) {
      _subscriptions.add(
        adapter.events.listen((event) {
          if (active != adapter || _sourceId != event.sourceId || busy) return;
          if (event.error != null) {
            error = event.error;
            notifyListeners();
          } else if (event.ended) {
            unawaited(next(expectedVersion: _playingVersion));
          }
        }),
      );
    }
  }
  final PartyState state;
  final List<PlaybackAdapter> adapters;
  final List<StreamSubscription<PlaybackEvent>> _subscriptions = [];
  PlaybackAdapter? active;
  String? _sourceId, error;
  int? _playingVersion;
  bool busy = false, paused = false, _disposed = false;

  Future<void> next({int? expectedVersion}) async {
    if (busy || !state.isOwner) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await active?.stop();
      final party = await state.advance(
        expectedVersion ?? state.party!.version,
      );
      await _play(party);
    } catch (e) {
      error = e is ApiError
          ? e.message
          : 'Playback interrupted. Reconnect or retry this song.';
      await state.refresh();
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> retry() async {
    if (busy || !state.isOwner) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _play(state.party!);
    } catch (_) {
      error = 'Could not play this song. Reconnect the music app or skip it.';
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _play(Party party) async {
    if (_disposed) return;
    final song = party.currentSong;
    _sourceId = null;
    if (song == null) {
      active = null;
      return;
    }
    for (final adapter in adapters) {
      final source = song.sources
          .where(
            (s) =>
                s.platform == adapter.platform &&
                party.platforms.contains(s.platform),
          )
          .firstOrNull;
      if (source == null) continue;
      await active?.stop();
      await adapter.connect();
      if (_disposed) return;
      active = adapter;
      _sourceId = source.id;
      _playingVersion = party.version;
      await adapter.play(source);
      paused = false;
      return;
    }
    throw ApiError('Connect a music platform that can play this song.');
  }

  Future<void> togglePause() async {
    if (active == null || busy) return;
    try {
      if (paused) {
        await active!.resume();
      } else {
        await active!.pause();
      }
      paused = !paused;
    } catch (_) {
      error = 'Playback disconnected. Try playing this song again.';
    }
    notifyListeners();
  }

  Future<void> stop() async {
    _sourceId = null;
    await active?.stop();
    active = null;
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    for (final adapter in adapters) {
      unawaited(adapter.dispose());
    }
    super.dispose();
  }
}
