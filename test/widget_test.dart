import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:song_voter/api.dart';
import 'package:song_voter/app.dart';
import 'package:song_voter/party_state.dart';

void main() {
  testWidgets('a new mobile guest sees a join action without a login screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = PartyState(SongVoterApi())..ready = true;
    await tester.pumpWidget(SongVoterApp(state: state));
    expect(find.text('Join'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
}
