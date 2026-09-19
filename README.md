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

A release requires `android/key.properties` with `storeFile`, `storePassword`,
`keyAlias`, and `keyPassword`. It never falls back to debug signing. Private keys
and this properties file are excluded from Git and container contexts. The
Android release workflow reads `ANDROID_KEYSTORE_BASE64` and
`ANDROID_KEYSTORE_PASSWORD` from encrypted repository secrets and publishes
`songvoter.apk` plus its SHA-256 checksum. Increment the pubspec version before
running another release. Back up the signing identity securely.

Debug APKs are test artifacts only. CI builds the Android test APK and the
website; the shared Coflnet workflow promotes the website image into `../fleet`.
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
API/database. CI also runs `integration_test/host_test.dart` on an Android emulator, checking
host creation, persistent QR visibility in both orientations, and ending a party.
Use the backend's test runner with `ANDROID_DEVICE=emulator-5554` to reproduce
both browser and native tests. Add `LIVE_PLAYBACK=true` on a provider-accessible
emulator to test actual YouTube start/pause/resume and automatic advance on end.
Spotify authorization and audible playback still need a Premium test account
and the registered app signing fingerprint; they are not simulated as success.
