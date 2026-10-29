# SongVoter usability review

This review follows the client code and existing tests. Provider authorization,
physical QR scanning and live backend playback were not exercised. Findings below
are ordered by likely impact on a first party; unimplemented ideas need separate work.

## Problems and the five selected changes

| Priority | Before | After |
| --- | --- | --- |
| 1 — guest request and vote | Search-result hearts use saved favourites, even inside a party. A saved song absent from the queue can offer removal instead of requesting it. Tooltips describe favourites rather than votes. | Party hearts use the matching queue entry, including in search results and the favourites tab. Labels distinguish requesting, voting and removing a vote. Personal favourites outside parties retain their existing behaviour. |
| 2 — first minute after joining | The large import panel precedes search and the queue, suggesting an account connection is the first step. | Inside a party, search and the queue precede optional imports. Existing surfaces, spacing, controls and colours are reused. |
| 3 — host setup | An empty or whitespace-only party name leaves Create party looking enabled, but tapping it does nothing. Setup content cannot scroll within its dialog. | An inline error explains the missing name, creation is disabled until corrected, and the dialog scrolls while keeping its actions available. |
| 4 — finding a song | Submitting fewer than two characters silently returns, potentially leaving old results on screen. | Inline guidance asks for two characters; stale results are cleared without sending a request. |
| 5 — action feedback | A successful request or vote may only update a heart or an off-screen queue. | A snackbar confirms a request, added vote or removed vote after completion. Pending and failed actions never show success. |

Every new message has an English source and a German translation.

## Flow walkthrough and remaining ideas

- **First host start:** Android/iOS offer Host a party below the manual join card;
  web offers the Android download. The host chooses a name, YouTube by default,
  and optionally Spotify. Making the native host action more prominent remains an
  opportunity, but guests also use the native app.
- **Connecting playback:** YouTube connects on playback; Spotify authorization
  precedes party creation and requires the Spotify app/Premium. Existing errors
  explain opening Spotify or using YouTube. Importing music lists is a separate
  account-connection flow; clearer separation from playback setup remains useful.
  A failed Spotify authorization closes setup and loses the entered party name;
  retaining that draft would reduce retries.
- **Creating and inviting:** Successful creation opens the persistent host stage
  with QR code, invite code and player. Copying the invite already has a snackbar;
  expired invites have a refresh action. The bare code button could better signal
  that it copies a link. The stage occupies substantial space on a small host screen.
- **Guest QR join:** `/join/<code>` creates an anonymous identity and joins during
  initialization, then displays the party name and members. No login is required.
  Manual code/link joining has validation. An explicit joined announcement and
  better recovery from expired invitations remain useful.
- **Search/request/vote:** Search accepts names or links and shows loading,
  provider warnings and a no-results suggestion. The selected changes remove the
  import detour, fix party-heart state and add feedback. A queue-empty call to focus
  search would make the existing empty-state wording more actionable.
- **During the party:** The host can start, advance, pause/resume and retry playback.
  Existing playback tests cover duplicate completion events, provider switching
  and retrying the same song. An unplayable queue entry explains that it is waiting
  for the host. There are no client controls/API methods for host removal,
  reordering or moderation; these need a backend capability review before design.
  Removing one's vote is not presented as removing a song from the party.
- **Ending:** A confirmation explains that playback stops, the invite closes and
  favourites persist. Leave calls the existing endpoint and clears local party
  state; disposal stops playback adapters. A final ended/left confirmation would
  improve orientation on return to the home screen.

## Regression checks

The five new tests live in the existing widget test file and use a request-overriding
fake API. They never connect to a backend or provider SDK. Existing tests were not edited.

All names below have the prefix `usability: `:

| Test name | Assertion and expected failure on pinned base b127d2ee60f041301732cc7fb2485481bd74205f |
| --- | --- |
| search-first | Search is above imports at 412 and 1280 pixels; the base has the opposite order. |
| queue-votes | A saved but unqueued song requests a song, then reflects the returned vote and unvoted queue state; base offers a favourites removal action. |
| search-guidance | Short searches show translated guidance and make no API call; base shows no guidance. |
| host-name | Blank names show an error and disable creation; a valid name enables it, and setup is scrollable; base has no error and leaves creation enabled. |
| action-feedback | Request, vote and vote-removal confirmations follow successful responses; pending/failing actions show none; base has no success snackbar. |

Focused patched tests pass. Exact-base execution belongs to the trusted gate;
the failure descriptions above are predictions from the unchanged source, not
claims of a locally executed base comparison. The temporary regression command
selects these five tests. Focused analysis covers the changed Dart files. The full
analyze/test/release-build suite is left to the trusted gate as instructed.

## Visual inspection

A debug web preview uses the real app with fake party data and no external requests.
Desktop (1440×1000) and mobile (390×844) screenshots were inspected for the English
empty queue and German short-search guidance. Search is immediately visible;
empty-state and import text wrap, surfaces align and new guidance remains legible.
Both browser reports contain no console/page errors or failed/blocked requests.
The existing import panel supplies the neighbouring shared visual system. New
heart tooltips supply action names; keyboard focus styling remains Material's.

A 390-pixel widget rendering with Flutter's test font exposes an existing app-bar
width overflow. The same browser width with the app font does not show clipping;
the ordering regression uses 412 pixels for its narrow layout. Native host dialog
and provider interaction have widget/code coverage only, not device screenshots.
