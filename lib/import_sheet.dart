import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api.dart';
import 'party_state.dart';
import 'strings.dart';

class ImportSheet extends StatefulWidget {
  const ImportSheet({
    super.key,
    required this.state,
    required this.provider,
    this.autoConnect = true,
    this.linkMode = false,
  });
  final PartyState state;
  final String provider;
  final bool autoConnect, linkMode;
  @override
  State<ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends State<ImportSheet> {
  final link = TextEditingController();
  final lists = <Map<String, dynamic>>[];
  String? error, next;
  bool busy = true, connected = false, available = true, paste = false;
  SongVoterApi get api => widget.state.api;
  String get provider => widget.provider;
  String get name => provider == 'youtube' ? 'YouTube' : 'Spotify';

  @override
  void initState() {
    super.initState();
    paste = widget.linkMode;
    WidgetsBinding.instance.addPostFrameCallback((_) => load(first: true));
  }

  @override
  void dispose() {
    link.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    if (!mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ApiError
              ? e.message
              : 'Connection interrupted. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> load({bool first = false}) => run(() async {
    final page = await api.request(
      'GET',
      '/api/import/$provider/lists${first || next == null ? '' : '?cursor=${Uri.encodeQueryComponent(next!)}'}',
    ) as Map<String, dynamic>;
    connected = page['connected'] as bool;
    available = page['available'] as bool;
    next = page['next'] as String?;
    if (first) lists.clear();
    lists.addAll((page['lists'] as List).cast<Map<String, dynamic>>());
    if (!connected && available && first && widget.autoConnect) {
      await authorize();
    }
  });

  Future<void> authorize() async {
    if (!mounted) return;
    final language = context.german ? 'de' : 'en';
    final random = Random.secure();
    final proof = List.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final response = await api.request(
      'POST',
      '/api/import/$provider/connect',
      {'proof': proof, 'native': !kIsWeb, 'language': language},
    ) as Map<String, dynamic>;
    await api.storage.write(
      key: 'musicImport',
      value: jsonEncode({
        'provider': provider,
        'state': response['state'],
        'proof': proof,
      }),
    );
    if (!await launchUrl(
      Uri.parse(response['url'] as String),
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_self',
    )) {
      throw ApiError('Could not open the music service. Please try again.');
    }
  }

  Future<void> import({String? id, String? url}) => run(() async {
    final result = await api.request('POST', '/api/import/$provider', {
      'listId': ?id,
      'url': ?url,
    }) as Map<String, dynamic>;
    await widget.state.loadFavourites();
    await widget.state.refresh();
    if (!mounted) return;
    final count = result['added'];
    final full = result['limitReached'] == true;
    final message = context.german
        ? '$count ${count == 1 ? 'Favorit' : 'Favoriten'} hinzugefügt.${full ? ' Deine 30 Plätze sind voll.' : ''}'
        : '$count ${count == 1 ? 'favourite' : 'favourites'} added.${full ? ' Your 30 spaces are full.' : ''}';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        18,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.german
                        ? 'Von $name importieren'
                        : 'Import from $name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: context.tr('Dismiss'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.german
                  ? 'Wähle eine Liste. Wir übernehmen bis zu 30 Favoriten. Vorhandene Songs bleiben erhalten, doppelte zählen nur einmal.'
                  : 'Choose a list. We’ll add up to 30 favourites. Existing songs stay saved and duplicates only count once.',
            ),
            const SizedBox(height: 16),
            if (busy) const LinearProgressIndicator(),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  context.tr(error!),
                  style: const TextStyle(color: Color(0xffffbbac)),
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  if (!connected || error != null) ...[
                    if (!available)
                      Text(
                        context.tr(
                          'Account import is not connected yet. You can still import a YouTube playlist link.',
                        ),
                      ),
                    if (available)
                      FilledButton.icon(
                        onPressed: busy ? null : () => run(authorize),
                        icon: const Icon(Icons.link),
                        label: Text(
                          context.german
                              ? 'Mit $name verbinden'
                              : 'Connect $name',
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      context.german
                          ? 'SongVoter liest nur deine Musiklisten. Wir ändern nichts in deinem Konto.'
                          : 'SongVoter only reads your music lists. We won’t change anything in your account.',
                    ),
                  ],
                  for (final list in lists)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          list['id'] == 'liked'
                              ? Icons.favorite
                              : Icons.queue_music,
                        ),
                        title: Text(
                          list['id'] == 'liked'
                              ? context.tr('Liked songs')
                              : list['name'] as String,
                        ),
                        subtitle: Text(
                          context.german
                              ? 'Antippen zum Importieren'
                              : 'Tap to import',
                        ),
                        trailing: const Icon(Icons.download_rounded),
                        onTap: busy
                            ? null
                            : () => import(id: list['id'] as String),
                      ),
                    ),
                  if (next != null)
                    TextButton(
                      onPressed: busy ? null : load,
                      child: Text(context.tr('More lists')),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => paste = !paste),
                    child: Text(context.tr('Use a playlist link instead')),
                  ),
                  if (paste) ...[
                    TextField(
                      controller: link,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: context.tr('Playlist link'),
                      ),
                      onSubmitted: busy
                          ? null
                          : (url) => import(url: url.trim()),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: busy
                          ? null
                          : () => import(url: link.text.trim()),
                      child: Text(context.tr('Import playlist')),
                    ),
                  ],
                  if (connected)
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => run(() async {
                              await api.request(
                                'DELETE',
                                '/api/import/$provider',
                              );
                              await api.storage.delete(key: 'musicImport');
                              connected = false;
                              lists.clear();
                              next = null;
                            }),
                      child: Text(context.tr('Disconnect account')),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
