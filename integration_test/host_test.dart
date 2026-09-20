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
    addTearDown(() async {
      if (state.api.userId != null) {
        await state.api.request('DELETE', '/api/user');
      }
      state.dispose();
    });
    await state.search('https://youtu.be/dX3k_QDnzHE');
    expect(state.results, isNotEmpty);
    final selected = state.results.single;
    await state.favourite(selected, true);
    await tester.pumpWidget(SongVoterApp(state: state));
    await tester.ensureVisible(find.text('Host a party'));
    await tester.tap(find.text('Host a party'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create party'));
    await until(() => state.party != null);
    await tester.pump(const Duration(seconds: 1));
    expect(
      find
          .widgetWithText(TextField, 'Find a song or paste a link')
          .hitTestable(),
      findsOneWidget,
    );
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
    await until(
      () => tester.view.physicalSize.width > tester.view.physicalSize.height,
    );
    checkQr();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await until(
      () => tester.view.physicalSize.height > tester.view.physicalSize.width,
    );
    await tester.tap(find.text('Start the music'));
    await until(() => state.party?.currentSong != null);
    expect(state.party!.currentSong!.id, selected.id);
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
      final duration = await controller.duration;
      expect(duration, greaterThan(1));
      await controller.seekTo(seconds: duration - 1, allowSeekAhead: true);
      await until(() => state.party!.version > version);
      checkQr();
    }
    await tester.tap(find.text('End party'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End party').last);
    await until(() => state.party == null);
    expect(find.text('Host a party'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  }, timeout: const Timeout(Duration(minutes: 5)));
}
