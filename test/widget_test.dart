import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:song_voter/api.dart';
import 'package:song_voter/app.dart';
import 'package:song_voter/party_state.dart';
import 'package:song_voter/models.dart';

final testSong = Song.fromJson({'id': 'song', 'title': 'Test song'});

Map<String, dynamic> guestParty({bool queued = false, bool voted = false}) => {
  'id': 'party',
  'name': 'Kitchen',
  'ownerId': 'host',
  'version': 1,
  'members': 2,
  'platforms': ['youtube'],
  'queue': [
    if (queued)
      {
        'song': {'id': 'song', 'title': 'Test song'},
        'favourite': voted,
        'playable': true,
        'votes': voted ? 1 : 0,
      },
  ],
};

class GuestApi extends SongVoterApi {
  GuestApi() : super(baseUrl: 'http://localhost');
  final calls = <String>[];
  Completer<dynamic>? action;
  @override
  Future<dynamic> request(String method, String path, [dynamic body]) async {
    calls.add('$method $path');
    if (path == '/api/lists/favourites') return {'id': 'list', 'songs': []};
    if (path == '/api/party/add' || path.startsWith('/api/party/removeVote/')) {
      return action != null
          ? action!.future
          : guestParty(queued: true, voted: true);
    }
    throw StateError('Unexpected request: $method $path');
  }
}

Future<void> showGuest(WidgetTester tester, PartyState state) async {
  await tester.pumpWidget(SongVoterApp(state: state));
  await tester.pumpAndSettle();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
}

void main() {
  testWidgets('usability: search-first', (tester) async {
    final state = PartyState(GuestApi())
      ..ready = true
      ..party = Party.fromJson(guestParty());
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    await showGuest(tester, state);
    for (final width in [412.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpAndSettle();
      final search = find.widgetWithText(
        TextField,
        'Find a song or paste a link',
      );
      await tester.ensureVisible(search);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(search).dy,
        lessThan(
          tester.getTopLeft(find.text('Your music is already out there.')).dy,
        ),
      );
    }
  });

  testWidgets('usability: queue-votes', (tester) async {
    final api = GuestApi();
    final state = PartyState(api)
      ..ready = true
      ..party = Party.fromJson(guestParty())
      ..results = [testSong]
      ..favourites = [testSong];
    await showGuest(tester, state);
    expect(find.byTooltip('Request song'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Request song'));
    await tester.tap(find.byTooltip('Request song'));
    await tester.pumpAndSettle();
    expect(api.calls.first, 'POST /api/party/add');
    expect(find.byTooltip('Remove vote'), findsNWidgets(2));
    state.party = Party.fromJson(guestParty(queued: true));
    state.changed();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Vote for song'), findsNWidgets(2));
  });

  testWidgets('usability: search-guidance', (tester) async {
    final api = GuestApi();
    final state = PartyState(api)
      ..ready = true
      ..party = Party.fromJson(guestParty());
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
    await showGuest(tester, state);
    for (final locale in ['en', 'de']) {
      tester.binding.platformDispatcher.localesTestValue = [Locale(locale)];
      await tester.pumpAndSettle();
      await state.search('a');
      await tester.pumpAndSettle();
      expect(
        find.text(
          locale == 'en'
              ? 'Enter at least two characters to search.'
              : 'Gib mindestens zwei Zeichen für die Suche ein.',
        ),
        findsOneWidget,
      );
    }
    tester.binding.platformDispatcher.clearLocalesTestValue();
    expect(api.calls, isEmpty);
  });

  testWidgets('usability: host-name', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final state = PartyState(GuestApi())..ready = true;
    await showGuest(tester, state);
    await tester.scrollUntilVisible(
      find.text('Host a party'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Host a party'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.pumpAndSettle();
    expect(find.text('Enter a party name.'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Create party'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable,
      isTrue,
    );
    await tester.enterText(find.byType(TextFormField), 'Kitchen');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Create party'),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('usability: action-feedback', (tester) async {
    final api = GuestApi()..action = Completer<dynamic>();
    final state = PartyState(api)
      ..ready = true
      ..party = Party.fromJson(guestParty())
      ..results = [testSong];
    await showGuest(tester, state);
    await tester.ensureVisible(find.byTooltip('Request song'));
    await tester.tap(find.byTooltip('Request song'));
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);
    api.action!.complete(guestParty(queued: true, voted: true));
    await tester.pumpAndSettle();
    expect(find.text('Song requested'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    for (final voted in [true, false]) {
      api.action = Completer<dynamic>();
      final action = find
          .byTooltip(voted ? 'Remove vote' : 'Vote for song')
          .first;
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pump();
      api.action!.complete(guestParty(queued: true, voted: !voted));
      await tester.pumpAndSettle();
      expect(find.text(voted ? 'Vote removed' : 'Vote added'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }
    api.action = Completer<dynamic>();
    await tester.ensureVisible(find.byTooltip('Remove vote').first);
    await tester.tap(find.byTooltip('Remove vote').first);
    await tester.pump();
    api.action!.completeError(ApiError('The queue changed. Please try again.'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    expect(state.error, 'The queue changed. Please try again.');
  });

  testWidgets(
    'German device locale localizes guest actions and Material controls',
    (tester) async {
      tester.binding.platformDispatcher.localesTestValue = const [
        Locale('de', 'DE'),
      ];
      addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
      final state = PartyState(SongVoterApi())..ready = true;
      await tester.pumpWidget(SongVoterApp(state: state));
      await tester.pumpAndSettle();
      expect(find.text('Beitreten'), findsOneWidget);
      expect(find.text('Partycode oder Einladungslink'), findsOneWidget);
      expect(find.text('Join'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    },
  );
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
