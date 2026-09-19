import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:song_voter/api.dart';
import 'package:song_voter/app.dart';
import 'package:song_voter/party_state.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native host creates a party, displays its QR, plays and ends it', (
    tester,
  ) async {
    final state = PartyState(SongVoterApi());
    Future<void> until(bool Function() condition) async {
      for (var i = 0; i < 120 && !condition(); i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(condition(), isTrue, reason: state.error);
    }

    await state.initialize();
    if (state.party != null) await state.leave();
    await state.search('Midnight City');
    expect(state.results, isNotEmpty);
    await state.favourite(state.results.first, true);
    await tester.pumpWidget(SongVoterApp(state: state));
    await tester.ensureVisible(find.text('Host a party'));
    await tester.tap(find.text('Host a party'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create party'));
    await until(() => state.party != null);
    await tester.pump(const Duration(seconds: 1));
    final qr = find.byType(QrImageView);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                'Scan to join at https://songvoter.party/join/${state.party!.code}',
      ),
      findsOneWidget,
    );
    void checkQr() {
      final bounds = tester.getRect(qr);
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(bounds.top, greaterThanOrEqualTo(0));
      expect(bounds.bottom, lessThanOrEqualTo(screen.height));
      expect(bounds.right, lessThanOrEqualTo(screen.width));
      expect(tester.takeException(), isNull);
    }

    checkQr();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    await tester.pump(const Duration(seconds: 2));
    checkQr();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Start the music'));
    await until(() => state.party?.currentSong != null);
    expect(state.party!.currentSong!.title, 'Midnight City');
    checkQr();
    if (const bool.fromEnvironment('LIVE_PLAYBACK')) {
      final controller = tester
          .widget<YoutubePlayer>(find.byType(YoutubePlayer))
          .controller;
      await until(() => controller.value.playerState == PlayerState.playing);
      await tester.tap(find.text('Pause'));
      await until(() => controller.value.playerState == PlayerState.paused);
      await tester.tap(find.text('Resume'));
      await until(() => controller.value.playerState == PlayerState.playing);
      final version = state.party!.version;
      await controller.seekTo(seconds: (await controller.duration) - 1);
      await until(() => state.party!.version > version);
      checkQr();
    }
    await tester.tap(find.text('End party'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End party').last);
    await until(() => state.party == null);
    expect(find.text('Host a party'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  }, timeout: const Timeout(Duration(minutes: 5)));
}
