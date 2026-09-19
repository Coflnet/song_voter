class SongSource {
  SongSource.fromJson(Map<String, dynamic> json)
    : platform = json['platform'] as String,
      id = json['externalId'] as String,
      artist = json['artist'] as String? ?? '',
      thumbnail = json['thumbnail'] as String?,
      durationMs = json['durationMs'] as int? ?? 0;
  final String platform, id, artist;
  final String? thumbnail;
  final int durationMs;
}

class Song {
  Song.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      title = json['title'] as String,
      sources = (json['occurences'] as List? ?? [])
          .map((e) => SongSource.fromJson(e as Map<String, dynamic>))
          .toList();
  final String id, title;
  final List<SongSource> sources;
  String get artist => sources.firstOrNull?.artist ?? '';
}

class QueueEntry {
  QueueEntry.fromJson(Map<String, dynamic> json)
    : song = Song.fromJson(json['song'] as Map<String, dynamic>),
      favourite = json['favourite'] as bool,
      playable = json['playable'] as bool,
      votes = json['votes'] as int;
  final Song song;
  final bool favourite, playable;
  final int votes;
}

class Party {
  Party.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String,
      ownerId = json['ownerId'] as String,
      joinUrl = json['joinUrl'] as String?,
      code = json['code'] as String?,
      version = json['version'] as int,
      members = json['members'] as int,
      platforms = (json['platforms'] as List).cast<String>(),
      currentSong = json['currentSong'] == null
          ? null
          : Song.fromJson(json['currentSong'] as Map<String, dynamic>),
      queue = (json['queue'] as List)
          .map((e) => QueueEntry.fromJson(e as Map<String, dynamic>))
          .toList();
  final String id, name, ownerId;
  final String? joinUrl, code;
  final int version, members;
  final List<String> platforms;
  final Song? currentSong;
  final List<QueueEntry> queue;
}
