import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'party_state.dart';
import 'playback/playback.dart';
import 'playback/native_adapters.dart';

class HostStage extends StatefulWidget {
  const HostStage({super.key, required this.state});
  final PartyState state;
  @override
  State<HostStage> createState() => _HostStageState();
}

class _HostStageState extends State<HostStage> with WidgetsBindingObserver {
  late final YoutubePlayback youtube;
  late final HostPlayback player;
  @override
  void initState() {
    super.initState();
    youtube = YoutubePlayback();
    player = HostPlayback(widget.state, [
      youtube,
      SpotifyPlayback(widget.state.api),
    ]);
    WidgetsBinding.instance.addObserver(this);
    unawaited(WakelockPlus.enable());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        player.active?.platform == 'youtube') {
      unawaited(player.active?.pause());
      player.paused = true;
    }
    if (state == AppLifecycleState.resumed) unawaited(widget.state.refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    player.dispose();
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: player,
    builder: (context, _) {
      final party = widget.state.party!;
      final qr = SizedBox(
        width: 172,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (party.joinUrl != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Semantics(
                  label: 'Scan to join at ${party.joinUrl}',
                  child: QrImageView(
                    data: party.joinUrl!,
                    size: 140,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'SCAN. ADD. DANCE.',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
            const Text(
              'songvoter.party',
              style: TextStyle(color: Color(0xffd4ff71)),
            ),
            TextButton(
              onPressed: party.joinUrl == null
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(text: party.joinUrl!),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invite link copied')),
                        );
                      }
                    },
              child: Text(party.code ?? 'Invite expired'),
            ),
            if (party.joinUrl == null)
              TextButton(
                onPressed: () => widget.state.perform(() async {
                  await widget.state.api.request(
                    'POST',
                    '/api/party/inviteLink',
                  );
                  await widget.state.refresh();
                }),
                child: const Text('Refresh invite'),
              ),
          ],
        ),
      );
      final playback = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Offstage(
            offstage: player.active?.platform == 'spotify',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: YoutubePlayer(
                controller: youtube.controller,
                enableFullScreenOnVerticalDrag: false,
                autoFullScreen: false,
              ),
            ),
          ),
          if (player.active?.platform == 'spotify')
            Container(
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff172b22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.graphic_eq_rounded,
                    size: 54,
                    color: Color(0xff1ed760),
                  ),
                  Text('Playing on Spotify'),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text(
            party.currentSong?.title ?? 'Ready when you are',
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            party.currentSong?.artist ??
                'Add a few favourites, then start the music.',
            style: const TextStyle(color: Color(0xffaaa7bc)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: player.busy || party.queue.every((e) => !e.playable)
                    ? null
                    : () => player.next(),
                icon: Icon(
                  party.currentSong == null
                      ? Icons.play_arrow_rounded
                      : Icons.skip_next_rounded,
                ),
                label: Text(
                  party.currentSong == null ? 'Start the music' : 'Next song',
                ),
              ),
              if (player.active != null)
                OutlinedButton.icon(
                  onPressed: player.togglePause,
                  icon: Icon(player.paused ? Icons.play_arrow : Icons.pause),
                  label: Text(player.paused ? 'Resume' : 'Pause'),
                ),
              if (party.currentSong != null && player.active == null)
                OutlinedButton(
                  onPressed: player.retry,
                  child: const Text('Resume this song'),
                ),
            ],
          ),
          if (player.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.error!,
                    style: const TextStyle(color: Color(0xffffbbac)),
                  ),
                  TextButton(
                    onPressed: player.busy ? null : player.retry,
                    child: const Text('Retry this song'),
                  ),
                ],
              ),
            ),
        ],
      );
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 28),
        decoration: BoxDecoration(
          color: const Color(0xff211d34),
          borderRadius: BorderRadius.circular(24),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 650
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: playback),
                    const SizedBox(width: 24),
                    qr,
                  ],
                )
              : Column(children: [playback, const SizedBox(height: 24), qr]),
        ),
      );
    },
  );
}
