import 'package:flutter/material.dart';

// Device/browser locale is resolved by MaterialApp, including German variants.
extension SongVoterStrings on BuildContext {
  bool get german => Localizations.localeOf(this).languageCode == 'de';
  String tr(String message) => german ? (_german[message] ?? message) : message;
}

const _german = <String, String>{
  "Liked songs": "Lieblingssongs",
  "More lists": "Weitere Listen",
  "Use a playlist link instead": "Stattdessen einen Playlistlink verwenden",
  "Playlist link": "Playlistlink",
  "Import playlist": "Playlist importieren",
  "Disconnect account": "Konto trennen",
  "Use my favourites": "Meine Favoriten nutzen",
  "Your favourites are in the party.": "Deine Favoriten sind in der Party.",
  "Account import is not connected yet. You can still import a YouTube playlist link.": "Der Kontoimport ist noch nicht verbunden. Du kannst weiterhin einen YouTube-Playlistlink importieren.",
  "Return to the browser or device where you started connecting.": "Kehre zu dem Browser oder Gerät zurück, auf dem du die Verbindung gestartet hast.",
  "Connection cancelled. Choose a service to try again.":
      "Verbindung abgebrochen. Wähle einen Dienst, um es erneut zu versuchen.",
  "The music account could not connect. Please try again.":
      "Das Musikkonto konnte nicht verbunden werden. Bitte versuche es erneut.",
  "Connect your music account to choose a list.":
      "Verbinde dein Musikkonto, um eine Liste auszuwählen.",
  "Reconnect your music account to continue.":
      "Verbinde dein Musikkonto erneut, um fortzufahren.",
  "The music service could not open this list. Check account access or try another playlist.": "Der Musikdienst konnte diese Liste nicht öffnen. Prüfe den Kontozugriff oder versuche eine andere Playlist.",
  "The music service is taking too long. Please try again.":
      "Der Musikdienst braucht zu lange. Bitte versuche es erneut.",
  "Choose a playlist or paste its full link.":
      "Wähle eine Playlist oder füge ihren vollständigen Link ein.",
  "Choose the matching music service for this playlist.":
      "Wähle den passenden Musikdienst für diese Playlist.",
  "Could not open the music service. Please try again.":
      "Der Musikdienst konnte nicht geöffnet werden. Bitte versuche es erneut.",
  "Connection expired. Choose a service to try again.": "Die Verbindung ist abgelaufen. Wähle einen Dienst, um es erneut zu versuchen.",
  "The queue changed. Please try again.":
      "Die Warteschlange hat sich geändert. Bitte versuche es erneut.",
  "This party's queue is full.": "Die Warteschlange dieser Party ist voll.",
  "Choose up to 30 favourites for this party.":
      "Wähle bis zu 30 Favoriten für diese Party.",

  "Make room for everyone’s music": "Platz für eure Lieblingsmusik",
  "My house party": "Meine Hausparty",
  "Party name": "Name der Party",
  "Play videos on this device": "Videos auf diesem Gerät abspielen",
  "Add Spotify": "Spotify hinzufügen",
  "Uses the Spotify app and your Premium account":
      "Mit der Spotify-App und deinem Premium-Konto",
  "Keep this screen open and connect your speakers. Guests only need the QR code.": "Lass diesen Bildschirm geöffnet und verbinde deine Lautsprecher. Deine Gäste brauchen nur den QR-Code.",
  "Cancel": "Abbrechen",
  "Create party": "Party erstellen",
  "End this party?": "Diese Party beenden?",
  "Leave this party?": "Diese Party verlassen?",
  "Playback stops and the invite closes. Everyone keeps their favourites.": "Die Musik stoppt und die Einladung wird geschlossen. Alle behalten ihre Favoriten.",
  "Your favourites stay saved for the next party.":
      "Deine Favoriten bleiben für die nächste Party gespeichert.",
  "Stay": "Bleiben",
  "End party": "Party beenden",
  "Leave": "Verlassen",
  "Your favourites stay on this device. No sign-in needed.": "Deine Favoriten bleiben in deinem Profil auf diesem Gerät gespeichert. Keine Anmeldung nötig.",
  "Getting your guest profile ready…": "Dein Gästeprofil wird vorbereitet …",
  "Try again": "Erneut versuchen",
  "Dismiss": "Schließen",
  "GOOD MUSIC. GREAT COMPANY.": "GUTE MUSIK. GUTE GESELLSCHAFT.",
  "Your favourites.\nEveryone’s party.": "Deine Favoriten.\nEure Party.",
  "Bring the songs you love. Let the room choose what’s next.": "Bring deine Lieblingssongs mit. Gemeinsam bestimmt ihr, was als Nächstes läuft.",
  "Add a song. Heart your favourites. We’ll take care of the queue.": "Füge Songs hinzu und markiere deine Favoriten mit einem Herz. Wir kümmern uns um die Reihenfolge.",
  "Got an invite?": "Du hast eine Einladung?",
  "Scan the host’s QR or enter the party code.":
      "Scanne den QR-Code oder gib den Partycode ein.",
  "Party code or invite link": "Partycode oder Einladungslink",
  "Join": "Beitreten",
  "Host a party": "Party veranstalten",
  "Get the Android host app": "Android-App zum Hosten herunterladen",
  "NOW PLAYING": "LÄUFT GERADE",
  "Find a song or paste a link": "Song suchen oder Link einfügen",
  "YouTube or Spotify": "YouTube oder Spotify",
  "Search songs": "Songs suchen",
  "Search results": "Suchergebnisse",
  "Clear": "Leeren",
  "Up next": "Als Nächstes",
  "Your favourites": "Deine Favoriten",
  "The dance floor is yours.": "Die Tanzfläche gehört euch.",
  "Add the first song and get everyone moving.":
      "Füge den ersten Song hinzu und bring alle zum Tanzen.",
  "Every party starts with a favourite.":
      "Jede Party beginnt mit einem Lieblingssong.",
  "Search for a song above. Your picks will follow you to the next party.": "Importiere eine Playlist oder suche einen Song. Deine Favoriten bleiben für die nächste Party gespeichert.",
  "Free to join. Free to add. Everyone gets a say.":
      "Kostenlos nutzen. Songs hinzufügen. Gemeinsam entscheiden.",
  "Invite link copied": "Einladungslink kopiert",
  "Invite expired": "Einladung abgelaufen",
  "Refresh invite": "Einladung erneuern",
  "Playing on Spotify": "Wiedergabe auf Spotify",
  "Ready when you are": "Bereit, wenn du es bist",
  "Add a few favourites, then start the music.":
      "Füge ein paar Favoriten hinzu und starte die Musik.",
  "Start the music": "Musik starten",
  "Next song": "Nächster Song",
  "Resume": "Fortsetzen",
  "Pause": "Pause",
  "Resume this song": "Diesen Song fortsetzen",
  "Retry this song": "Diesen Song erneut versuchen",
  "Connection interrupted. Please try again.":
      "Verbindung unterbrochen. Bitte versuche es erneut.",
  "Reconnecting to the party…": "Verbindung zur Party wird wiederhergestellt …",
  "Enter the party code or paste its invite link.":
      "Gib den Partycode ein oder füge den Einladungslink ein.",
  "No songs found. Try another artist or paste a song link.": "Keine Songs gefunden. Versuche einen anderen Künstler oder füge einen Songlink ein.",
  "Search is unavailable. Please retry.":
      "Die Suche ist gerade nicht verfügbar. Bitte versuche es erneut.",
  "The party changed. Please retry.":
      "Die Party hat sich geändert. Bitte versuche es erneut.",
  "Connecting took too long. Please retry.":
      "Der Verbindungsaufbau hat zu lange gedauert. Bitte versuche es erneut.",
  "Please try again.": "Bitte versuche es erneut.",
  "A little too fast. Give it a moment, then try again.":
      "Das war etwas zu schnell. Warte einen Moment und versuche es erneut.",
  "Could not connect to the party. Please retry.":
      "Die Verbindung zur Party ist fehlgeschlagen. Bitte versuche es erneut.",
  "YouTube cannot play this video here. Retry or skip it.": "YouTube kann dieses Video hier nicht abspielen. Versuche es erneut oder überspringe es.",
  "Spotify disconnected. Reconnect and retry this song.": "Die Spotify-Verbindung wurde getrennt. Verbinde Spotify erneut und starte den Song noch einmal.",
  "Spotify is not connected to SongVoter yet. You can host with YouTube.": "Spotify ist noch nicht mit SongVoter verbunden. Du kannst YouTube nutzen.",
  "Install Spotify and sign in on this device, then try again.":
      "Installiere Spotify und melde dich dort an. Versuche es dann erneut.",
  "Open Spotify on this device, then try connecting again.": "Öffne Spotify auf diesem Gerät und versuche erneut, die Verbindung herzustellen.",
  "Spotify could not connect. Open Spotify, check your Premium account, and try again.": "Spotify konnte keine Verbindung herstellen. Öffne Spotify, prüfe dein Premium-Konto und versuche es erneut.",
  "Playback interrupted. Reconnect or retry this song.": "Wiedergabe unterbrochen. Verbinde die App erneut oder starte den Song noch einmal.",
  "Could not play this song. Reconnect the music app or skip it.": "Dieser Song konnte nicht abgespielt werden. Verbinde die Musik-App erneut oder überspringe ihn.",
  "Connect a music platform that can play this song.":
      "Verbinde eine Musikplattform, die diesen Song abspielen kann.",
  "Playback disconnected. Try playing this song again.":
      "Die Wiedergabe wurde getrennt. Versuche den Song erneut zu starten.",
  "This invite has expired or the party has ended.":
      "Diese Einladung ist abgelaufen oder die Party wurde beendet.",
  "Leave your current party before joining another.": "Verlasse zuerst deine aktuelle Party, bevor du einer anderen beitrittst.",
  "Leave your current party first.": "Verlasse zuerst deine aktuelle Party.",
  "This party is full.": "Diese Party ist voll.",
  "Give your party a name.": "Gib deiner Party einen Namen.",
  "Choose YouTube, Spotify, or both.": "Wähle YouTube, Spotify oder beides.",
  "Choose up to 30 favourites. Remove one to make room.": "Du kannst bis zu 30 Favoriten speichern. Entferne einen, um Platz zu schaffen.",
  "Your favourites are full. Remove a song before adding another.": "Deine Favoriten sind voll. Entferne einen Song, bevor du einen neuen hinzufügst.",
  "Song not found.": "Song nicht gefunden.",
  "This song is unavailable for playback.":
      "Dieser Song ist nicht zur Wiedergabe verfügbar.",
  "Playback has already advanced. Refresh the queue.":
      "Der nächste Song läuft bereits. Aktualisiere die Warteschlange.",
  "Paste a YouTube or Spotify song link.":
      "Füge einen YouTube- oder Spotify-Songlink ein.",
  "Use a link to a song or video on YouTube or Spotify.":
      "Verwende einen Link zu einem Song oder Video auf YouTube oder Spotify.",
  "The party queue is full.": "Die Warteschlange der Party ist voll.",
  "Please retry connecting to the party.":
      "Bitte versuche erneut, dich mit der Party zu verbinden.",
  "This challenge has already been used.": "Diese Verbindungsanfrage wurde bereits verwendet. Bitte versuche es erneut.",
  "Youtube search is temporarily unavailable.":
      "Die Suche auf Youtube ist vorübergehend nicht verfügbar.",
  "Youtube search is not connected yet.":
      "Die Suche auf Youtube ist noch nicht verbunden.",
  "Youtube search is temporarily unavailable. You can still choose other results.": "Die Suche auf Youtube ist vorübergehend nicht verfügbar. Du kannst andere Ergebnisse auswählen.",
  "Youtube could not load that song. Try another link.":
      "Youtube konnte diesen Song nicht laden. Versuche einen anderen Link.",
  "Spotify search is temporarily unavailable.":
      "Die Suche auf Spotify ist vorübergehend nicht verfügbar.",
  "Spotify search is not connected yet.":
      "Die Suche auf Spotify ist noch nicht verbunden.",
  "Spotify search is temporarily unavailable. You can still choose other results.": "Die Suche auf Spotify ist vorübergehend nicht verfügbar. Du kannst andere Ergebnisse auswählen.",
  "Spotify could not load that song. Try another link.":
      "Spotify konnte diesen Song nicht laden. Versuche einen anderen Link.",
};
