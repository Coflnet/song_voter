import 'package:flutter/material.dart';
import 'package:song_voter/widgets/base/base.dart';
import 'package:song_voter/widgets/login/google_signin/google_signin_view.dart';
import 'package:song_voter/widgets/youtube_player/youtube_player_view.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Base(
      showNavbar: true,
      navbarIndex: 2,
      child: Center(child: YoutubePlayerView()),
    );
  }
}
