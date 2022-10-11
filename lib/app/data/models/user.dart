import 'package:song_voter/app/data/models/user.dart';

class User {
  User(
      {this.id,
      required this.username,
      this.googleId,
      this.appleId,
      this.guestId
      //TODO user avatar would be awesome
      });

  final int? id;
  final String username;
  final String? googleId;
  final String? appleId;
  final String? guestId;

  User copy({
    int? id,
    String? username,
    String? googleId,
    String? appleId,
    String? guestId,
  }) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        googleId: googleId ?? this.googleId,
        appleId: appleId ?? this.appleId,
        guestId: guestId ?? this.guestId,
      );

  static User fromJson(Map<String, Object?> json) => User(
        id: json[UserFields.id] as int?,
        googleId: json[UserFields.googleId] as String?,
        appleId: json[UserFields.appleId] as String?,
        guestId: json[UserFields.guestId] as String?,
        username: json[UserFields.username]! as String,
      );

  Map<String, Object?> toJson() => {
        UserFields.id: id,
        UserFields.googleId: googleId,
        UserFields.appleId: appleId,
        UserFields.guestId: guestId,
        UserFields.username: username,
      };
}

class UserFields {
  static final List<String> values = [
    id,
    googleId,
    appleId,
    guestId,
    username,
  ];

  static const String id = '_id';
  static const String googleId = 'google_id';
  static const String appleId = 'apple_id';
  static const String guestId = 'guest_id';
  static const String username = 'username';
}
