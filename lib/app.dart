import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api.dart';
import 'host_stage.dart';
import 'models.dart';
import 'party_state.dart';
import 'playback/native_adapters.dart';

const ink = Color(0xff12101d);
const surface = Color(0xff211d30);
const muted = Color(0xffb2adc5);
const lime = Color(0xffd4ff71);

class SongVoterApp extends StatelessWidget {
  const SongVoterApp({super.key, this.state});
  final PartyState? state;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SongVoter · Everyone gets a say',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xffac8bfa),
        brightness: Brightness.dark,
        primary: lime,
        surface: surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
      dividerColor: const Color(0xff383147),
    ),
    home: PartyHome(state: state),
  );
}

class PartyHome extends StatefulWidget {
  const PartyHome({super.key, this.state});
  final PartyState? state;
  @override
  State<PartyHome> createState() => _PartyHomeState();
}

class _PartyHomeState extends State<PartyHome> {
  late final PartyState state;
  final search = TextEditingController(), code = TextEditingController();
  StreamSubscription<Uri>? _links;
  int tab = 0;
  String? initialInvite;
  bool get nativeHost =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  @override
  void initState() {
    super.initState();
    state = widget.state ?? PartyState(SongVoterApi());
    final path = Uri.base.pathSegments;
    initialInvite = path.length == 2 && path.first == "join"
        ? PartyState.inviteCode(path.last)
        : null;
    if (!state.ready) unawaited(state.initialize(initialInvite));
    if (!kIsWeb) {
      _links = AppLinks().uriLinkStream.listen((uri) {
        final invite = PartyState.inviteCode(uri.toString());
        if (invite != null) unawaited(state.join(invite));
      });
    }
  }

  @override
  void dispose() {
    unawaited(_links?.cancel());
    if (widget.state == null) state.dispose();
    search.dispose();
    code.dispose();
    super.dispose();
  }

  Future<void> host() async {
    var name = 'My house party';
    var spotify = false;
    final result = await showDialog<(String, bool)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Make room for everyone’s music'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  onChanged: (value) => name = value,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'Party name'),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.smart_display_outlined),
                  title: Text('YouTube'),
                  subtitle: Text('Play videos on this device'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: spotify,
                  onChanged: (value) => update(() => spotify = value),
                  title: const Text('Add Spotify'),
                  subtitle: const Text(
                    'Uses the Spotify app and your Premium account',
                  ),
                ),
                const Text(
                  'Keep this screen open and connect your speakers. Guests only need the QR code.',
                  style: TextStyle(color: muted),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (name.trim().isNotEmpty) {
                  Navigator.pop(context, (name.trim(), spotify));
                }
              },
              child: const Text('Create party'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      if (result.$2) {
        await state.perform(() => SpotifyPlayback.authorize(state.api));
        if (state.error != null) return;
      }
      await state.create(result.$1, ['youtube', if (result.$2) 'spotify']);
    }
  }

  Future<void> leave() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(state.isOwner ? 'End this party?' : 'Leave this party?'),
        content: Text(
          state.isOwner
              ? 'Playback stops and the invite closes. Everyone keeps their favourites.'
              : 'Your favourites stay saved for the next party.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(state.isOwner ? 'End party' : 'Leave'),
          ),
        ],
      ),
    );
    if (yes == true) await state.leave();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      final party = state.party;
      final hosting = nativeHost && state.isOwner;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: ink,
          surfaceTintColor: ink,
          centerTitle: false,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.graphic_eq_rounded, color: lime),
              SizedBox(width: 10),
              Text(
                'songvoter',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          actions: [
            if (party != null)
              TextButton(
                onPressed: state.busy ? null : leave,
                child: Text(state.isOwner ? 'End party' : 'Leave'),
              ),
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Tooltip(
                message:
                    'Your favourites stay on this device. No sign-in needed.',
                child: Icon(Icons.account_circle_outlined, color: muted),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: !state.ready
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.busy) const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          state.error ?? 'Getting your guest profile ready…',
                          textAlign: TextAlign.center,
                        ),
                        if (!state.busy)
                          FilledButton(
                            onPressed: () => state.initialize(initialInvite),
                            child: const Text('Try again'),
                          ),
                      ],
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      children: [
                        if (state.busy)
                          const LinearProgressIndicator(minHeight: 2),
                        if (state.error != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xff452b35),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline),
                                const SizedBox(width: 12),
                                Expanded(child: Text(state.error!)),
                                IconButton(
                                  tooltip: 'Dismiss',
                                  onPressed: () {
                                    state.error = null;
                                    state.changed();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                        if (hosting)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: HostStage(
                              key: ValueKey(party!.id),
                              state: state,
                            ),
                          ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: state.refresh,
                            child: ListView(
                              key: ValueKey(party?.id ?? 'home'),
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                20,
                                24,
                                40,
                              ),
                              children: [
                                if (!hosting) ...[
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: lime,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          party == null
                                              ? 'GOOD MUSIC. GREAT COMPANY.'
                                              : 'LIVE PARTY · ${party.members} ${party.members == 1 ? 'PERSON' : 'PEOPLE'}',
                                          style: const TextStyle(
                                            color: lime,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    party?.name ??
                                        'Your favourites.\nEveryone’s party.',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.sizeOf(context).width < 500
                                          ? 38
                                          : 58,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    party == null
                                        ? 'Bring the songs you love. Let the room choose what’s next.'
                                        : 'Add a song. Heart your favourites. We’ll take care of the queue.',
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 17,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                ],
                                if (party == null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: surface,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          'Got an invite?',
                                          style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Scan the host’s QR or enter the party code.',
                                          style: TextStyle(color: muted),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: code,
                                                autocorrect: false,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Party code or invite link',
                                                      fillColor: ink,
                                                    ),
                                                onSubmitted: (_) =>
                                                    state.join(code.text),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            FilledButton(
                                              onPressed: state.busy
                                                  ? null
                                                  : () => state.join(code.text),
                                              child: const Text('Join'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (nativeHost)
                                    FilledButton.icon(
                                      onPressed: state.busy ? null : host,
                                      icon: const Icon(
                                        Icons.speaker_group_outlined,
                                      ),
                                      label: const Text('Host a party'),
                                    )
                                  else
                                    OutlinedButton.icon(
                                      onPressed: () => launchUrl(
                                        Uri.parse(
                                          'https://songvoter.party/downloads/songvoter.apk',
                                        ),
                                        mode: LaunchMode.externalApplication,
                                      ),
                                      icon: const Icon(Icons.phone_android),
                                      label: const Text(
                                        'Get the Android host app',
                                      ),
                                    ),
                                  const SizedBox(height: 32),
                                ],
                                if (party?.currentSong != null && !hosting)
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    margin: const EdgeInsets.only(bottom: 28),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xff3c2b60),
                                          Color(0xff242037),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.equalizer,
                                          color: lime,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'NOW PLAYING',
                                                style: TextStyle(
                                                  color: lime,
                                                  fontSize: 11,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                              Text(
                                                party!.currentSong!.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                              Text(
                                                party.currentSong!.artist,
                                                style: const TextStyle(
                                                  color: muted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                TextField(
                                  controller: search,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                    labelText: 'Find a song or paste a link',
                                    hintText: 'YouTube or Spotify',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: IconButton(
                                      tooltip: 'Search songs',
                                      onPressed: state.searching
                                          ? null
                                          : () => state.search(search.text),
                                      icon: const Icon(
                                        Icons.arrow_forward_rounded,
                                      ),
                                    ),
                                  ),
                                  onSubmitted: state.search,
                                ),
                                if (state.searching)
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: LinearProgressIndicator(),
                                  ),
                                for (final warning in state.searchWarnings)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      warning,
                                      style: const TextStyle(color: muted),
                                    ),
                                  ),
                                if (state.results.isNotEmpty) ...[
                                  const SizedBox(height: 22),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Search results',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          state.results = [];
                                          search.clear();
                                          state.changed();
                                        },
                                        child: const Text('Clear'),
                                      ),
                                    ],
                                  ),
                                  for (final song in state.results)
                                    songRow(song),
                                ],
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SegmentedButton<int>(
                                        showSelectedIcon: false,
                                        segments: [
                                          if (party != null)
                                            const ButtonSegment(
                                              value: 0,
                                              label: Text('Up next'),
                                              icon: Icon(Icons.queue_music),
                                            ),
                                          const ButtonSegment(
                                            value: 1,
                                            label: Text('Your favourites'),
                                            icon: Icon(Icons.favorite_outline),
                                          ),
                                        ],
                                        selected: {party == null ? 1 : tab},
                                        onSelectionChanged: (value) =>
                                            setState(() => tab = value.first),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                if (party != null && tab == 0) ...[
                                  if (party.queue.isEmpty)
                                    empty(
                                      'The dance floor is yours.',
                                      'Add the first song and get everyone moving.',
                                    ),
                                  for (var i = 0; i < party.queue.length; i++)
                                    songRow(
                                      party.queue[i].song,
                                      entry: party.queue[i],
                                      position: i + 1,
                                    ),
                                ] else ...[
                                  if (state.favourites.isEmpty)
                                    empty(
                                      'Every party starts with a favourite.',
                                      'Search for a song above. Your picks will follow you to the next party.',
                                    ),
                                  for (final song in state.favourites)
                                    songRow(song),
                                ],
                                const SizedBox(height: 22),
                                const Text(
                                  'Free to join. Free to add. Everyone gets a say.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      );
    },
  );

  Widget empty(String title, String description) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        const Icon(
          Icons.music_note_rounded,
          size: 42,
          color: Color(0xffac8bfa),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, height: 1.5),
        ),
      ],
    ),
  );

  Widget songRow(Song song, {QueueEntry? entry, int? position}) {
    final favourite =
        entry?.favourite ?? state.favourites.any((s) => s.id == song.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          leading: position != null
              ? SizedBox(
                  width: 28,
                  child: Text(
                    '$position',
                    style: const TextStyle(color: muted, fontSize: 18),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: song.sources.firstOrNull?.thumbnail != null
                      ? Image.network(
                          song.sources.first.thumbnail!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.music_note, size: 36),
                        )
                      : const Icon(
                          Icons.music_note,
                          size: 36,
                          color: Color(0xffac8bfa),
                        ),
                ),
          title: Text(
            song.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${song.artist}\n${song.sources.map((s) => s.platform == 'youtube' ? 'YouTube' : 'Spotify').join(' · ')}${entry != null && !entry.playable ? ' · Waiting for host to connect' : ''}',
            style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
          ),
          trailing: IconButton.filledTonal(
            tooltip: favourite
                ? 'Remove ${song.title} from favourites'
                : 'Add ${song.title} to favourites',
            onPressed: state.busy
                ? null
                : () => state.favourite(song, !favourite),
            icon: Icon(
              favourite ? Icons.favorite : Icons.favorite_border,
              color: favourite ? lime : null,
            ),
          ),
        ),
      ),
    );
  }
}
