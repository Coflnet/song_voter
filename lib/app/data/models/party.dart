import 'package:song_voter/app/data/models/user.dart';

class Party {
  Party(
      {this.id,
      required this.name,
      this.description,
      required this.private,
      required this.createdAt,
      this.users = const []});

  final int? id;
  final String name;
  final String? description;
  final List<User> users;
  final bool private;
  final DateTime createdAt;

  Party copy({
    int? id,
    String? name,
    String? description,
    List<User>? users,
    bool? private,
    DateTime? createdAt,
  }) =>
      Party(
          id: id ?? this.id,
          name: name ?? this.name,
          description: description ?? this.description,
          users: users ?? this.users,
          private: private ?? this.private,
          createdAt: createdAt ?? this.createdAt);

  static Party fromJson(Map<String, Object?> json) => Party(
        id: json[PartyFields.id] as int?,
        name: json[PartyFields.name]! as String,
        description: json[PartyFields.description] as String?,
        private: json[PartyFields.private]! == 1,
        createdAt: DateTime.parse(json[PartyFields.createdAt]! as String),
      );

  Map<String, Object?> toJson() => {
        PartyFields.id: id,
        PartyFields.name: name,
        PartyFields.private: private ? 1 : 0,
        PartyFields.createdAt: createdAt.toIso8601String(),
      };
}

class PartyFields {
  static final List<String> values = [
    /// Add all fields
    id, name, description, private, createdAt
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String description = 'description';
  static const String private = 'private';
  static const String createdAt = 'createdAt';
}
