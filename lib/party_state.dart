import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api.dart';
import 'models.dart';

class PartyState extends ChangeNotifier {
  PartyState(this.api);
  final SongVoterApi api;
  Party? party;
  List<Song> favourites = [], results = [];
  String? listId, error;
  List<String> searchWarnings = [];
  bool ready = false, busy = false, searching = false;
  Timer? _poll;
  bool _refreshing = false, _disposed = false;
  int _generation = 0;
  bool get isOwner => party != null && party!.ownerId == api.userId;

  void changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> perform(Future<void> Function() action) async {
    if (busy) return;
    _generation++;
    busy = true;
    error = null;
    changed();
    try {
      await action();
    } catch (e) {
      error = e is ApiError
          ? e.message
          : 'Connection interrupted. Please try again.';
    } finally {
      busy = false;
      changed();
    }
  }

  Future<void> initialize([String? invite]) => perform(() async {
    await api.connect();
    await loadFavourites();
    ready = true;
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 4), (_) {
      if (party != null && !busy) unawaited(refresh());
    });
    if (invite != null) {
      party = Party.fromJson(
        await api.request('POST', '/api/party/$invite/join')
            as Map<String, dynamic>,
      );
    } else {
      await refresh();
    }
  });

  Future<void> loadFavourites() async {
    final data = await api.request(
      'GET',
      '/api/lists/favourites',
    ) as Map<String, dynamic>;
    listId = data['id'] as String;
    favourites = (data['songs'] as List)
        .map((s) => Song.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    final generation = _generation;
    try {
      final data =
          await api.request('GET', '/api/party') as Map<String, dynamic>;
      if (generation == _generation) party = Party.fromJson(data);
    } on ApiError catch (e) {
      if (generation == _generation && e.status == 404) {
        party = null;
      } else if (generation == _generation) {
        error = e.message;
      }
    } catch (_) {
      error = 'Reconnecting to the party…';
    } finally {
      _refreshing = false;
      changed();
    }
  }

  Future<void> join(String input) => perform(() async {
    final code = inviteCode(input);
    if (code == null) {
      throw ApiError('Enter the party code or paste its invite link.');
    }
    _generation++;
    party = Party.fromJson(
      await api.request('POST', '/api/party/$code/join')
          as Map<String, dynamic>,
    );
    ready = true;
  });

  static String? inviteCode(String input) {
    final value = input.trim();
    final uri = Uri.tryParse(value);
    final code =
        uri != null &&
            uri.scheme == 'https' &&
            uri.host == 'songvoter.party' &&
            uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'join'
        ? uri.pathSegments.last
        : value;
    return RegExp(r'^[a-f0-9]{12}$', caseSensitive: false).hasMatch(code)
        ? code.toLowerCase()
        : null;
  }

  Future<void> create(String name, List<String> platforms) => perform(() async {
    _generation++;
    party = Party.fromJson(
      await api.request('POST', '/api/party', {
        'name': name,
        'supportedPlatforms': platforms,
      }) as Map<String, dynamic>,
    );
  });

  Future<void> search(String term) async {
    if (term.trim().length < 2 || searching) return;
    searching = true;
    error = null;
    searchWarnings = [];
    changed();
    try {
      final data = await api.request(
        'GET',
        '/api/songs/search?term=${Uri.encodeQueryComponent(term.trim())}',
      ) as Map<String, dynamic>;
      results = data.containsKey('songs')
          ? (data['songs'] as List)
                .map((s) => Song.fromJson(s as Map<String, dynamic>))
                .toList()
          : [Song.fromJson(data)];
      searchWarnings = (data['warnings'] as List? ?? []).cast<String>();
      if (results.isEmpty && searchWarnings.isEmpty) {
        searchWarnings = [
          'No songs found. Try another artist or paste a song link.',
        ];
      }
    } catch (e) {
      error = e is ApiError
          ? e.message
          : 'Search is unavailable. Please retry.';
    } finally {
      searching = false;
      changed();
    }
  }

  Future<void> favourite(Song song, bool value) => perform(() async {
    if (party != null) {
      final data = value
          ? await api.request('POST', '/api/party/add', [song.id])
          : await api.request('POST', '/api/party/removeVote/${song.id}');
      party = Party.fromJson(data as Map<String, dynamic>);
    } else {
      await api.request(
        value ? 'POST' : 'DELETE',
        value
            ? '/api/lists/$listId/songs'
            : '/api/lists/$listId/songs/${song.id}',
        value ? {'id': song.id} : null,
      );
    }
    await loadFavourites();
  });

  Future<void> useFavourites() => perform(() async {
    if (party == null || favourites.isEmpty) return;
    party = Party.fromJson(
      await api.request(
        'POST',
        '/api/party/add',
        favourites.take(30).map((s) => s.id).toList(),
      ) as Map<String, dynamic>,
    );
  });

  Future<Party> advance(int version) async {
    final generation = ++_generation;
    final updated = Party.fromJson(
      await api.request('POST', '/api/party/next', {'version': version})
          as Map<String, dynamic>,
    );
    if (generation != _generation) {
      throw ApiError('The party changed. Please retry.', 409);
    }
    _generation++;
    party = updated;
    changed();
    return updated;
  }

  Future<void> leave() => perform(() async {
    await api.request('POST', '/api/party/leave');
    _generation++;
    party = null;
  });

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    api.dispose();
    super.dispose();
  }
}
