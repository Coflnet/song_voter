# SongVoter

Scan the host's QR, add a song, and heart your favourites. A guest profile is
created automatically and saved on the device. No email, password, or account
screen is required. YouTube and Spotify links share one party queue.

Android is the primary host; iOS uses the same playback adapters and app source.
The website is for guests. The host connects speakers, creates an event, and
keeps the player/QR screen open. YouTube uses its visible IFrame player; Spotify
uses the installed Spotify app through App Remote. Guests need neither SDK nor
provider account. Spotify hosts need an eligible Premium account and must grant
Spotify's requested authorization.

## Develop

Use Flutter **3.47.5** / Dart 3.13 or newer compatible versions:

```
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4200
flutter build web --release
flutter build apk --debug
```

For an Android emulator use `http://10.0.2.2:4200`. Production defaults to
`https://songvoter.party`; the web app uses its current origin and nginx proxies
the API. Serve the web build through nginx so `/join/<code>` opens the app.

Configure the Spotify developer app with package/bundle ID
`com.coflnet.songvoter`, your signing certificate's SHA-1, and redirect URI
`com.coflnet.songvoter://spotify-callback`. The public client ID comes from
`/api/config`; no client secret is included in the app. Register each testing
account with Spotify when the provider app is in development mode.

A release must use your permanent Android signing key. Debug APKs are test
artifacts only. CI builds the Android test APK and the website; the shared
Coflnet workflow promotes the website image into `../fleet`. Publish a signed
release asset named `songvoter.apk` before enabling the website's download link.
Apple builds require macOS/Xcode and an Apple signing identity; they cannot be
validated on the Linux development host.

## Extend

* `api.dart`: secure device identity, background proof of work, token renewal.
* `party_state.dart`: favourites, invite joins, queue updates, and request errors.
* `playback/playback.dart`: provider-independent playback coordinator. Provider
  end events carry a source ID; the API also checks the playback version so a
  duplicate or delayed callback cannot skip a song.
* `playback/native_adapters.dart`: YouTube and Spotify adapters. Add another
  adapter plus its backend `IMusicCatalog` implementation for a new provider.
* `app.dart` / `host_stage.dart`: guest interface and persistent host QR/player.

Favourites belong to the profile that created them. Clearing app/browser storage
loses the anonymous profile; it is intentionally not recoverable by guessing a
public profile ID. Proof of work and rate limits raise the cost of anonymous
spam, while normalizing each profile's contribution keeps long lists from
multiplying its influence. They do not establish a unique real-world person.

Everything is free. Paid priority is disabled. Any future boost must be awarded
by a verified backend payment event, with provider policy review first; a client
must never be able to set its own priority.

## Verification

`flutter test` covers proof compatibility, mobile onboarding, join links,
provider switching, duplicate callbacks, pauses, and retrying failed playback.
`../SongVoter/tests/browser` covers a real Chromium guest against the live local
API/database. Provider playback/account permissions still require a device
smoke test; unit tests use playback adapters without a Spotify account.
