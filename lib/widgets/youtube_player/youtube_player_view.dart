import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:song_voter/widgets/base/base.dart';
import 'package:song_voter/widgets/party/create/party_create_controller.dart';
import 'package:song_voter/widgets/youtube_player/youtube_player_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerView extends GetView<YoutubePlayerGetController> {
  final YoutubePlayerController _youtubeController = YoutubePlayerController(
    initialVideoId: 'dQw4w9WgXcQ',
    flags: YoutubePlayerFlags(
      autoPlay: true,
      mute: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: YoutubePlayer(
              controller: _youtubeController,
              showVideoProgressIndicator: true,
              progressColors: ProgressBarColors(
                playedColor: Colors.amber,
                handleColor: Colors.amberAccent,
              ),
              bottomActions: [
                CurrentPosition(),
                ProgressBar(
                  isExpanded: true,
                ),
                RemainingDuration()
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.033,
                right: MediaQuery.of(context).size.width * 0.03,
                left: MediaQuery.of(context).size.width * 0.03),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Title'),
              onChanged: (value) => {controller.videoSearchText(value)},
            ),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.075,
              child: TextButton(
                  onPressed: () {
                    controller.onSearch();
                  },
                  child: Text(
                      style: Theme.of(context).textTheme.headline5, "Search")),
            ),
          ),
        ],
      ),
    );
  }
}
