# Fairhaven Music

Fairhaven Music is the music app for the Fairhaven Music service. It connects to
https://listen.fairhavenmusic.net and lets members stream and download music on
iPhone and Android.

Need an account or a password reset? Visit https://it.fairhavenbaptist.org/music-app/

## Based on Finamp

This app is a modified version of [Finamp](https://github.com/finamp-app/finamp),
an open source music player created by the Finamp contributors. Thank you to
everyone who built it. The original project's README is kept in
[FINAMP_README.md](FINAMP_README.md).

Fairhaven Music is not affiliated with or endorsed by the Finamp project or
Jellyfin. "Finamp" and "Jellyfin" are names of their respective projects and
are used here only to credit the original work.

## License

Finamp is licensed under the [Mozilla Public License 2.0](LICENSE), and so is
this modified version. The complete source code for Fairhaven Music, including
all changes made to the original, is available in this repository.

## Main changes from Finamp

- Fairhaven Music name, logo, and burgundy theme
- Locked to the Fairhaven Music server, with a simplified sign-in
  (no Quick Connect, no client certificates)
- English only
- Private playlists only; deleting songs and albums from the server is disabled
- Lyrics and Discord Rich Presence removed

## UI refresh (2026)

The interface was refreshed without changing behavior, colors, icons or app IDs.
Shared type and shapes live in `lib/fairhaven_theme.dart`. Headings use Literata
(bundled in `assets/fonts`, SIL Open Font License); body text uses the platform font.

## Building

This is a Flutter app. Branding settings (server address, colors, and links)
live in `lib/branding.dart`.

```
flutter pub get
flutter build appbundle --release   # Android
flutter build ipa --release         # iOS (requires macOS or a cloud build service)
```

Only the Android and iOS apps are maintained. The desktop folders (macOS,
Windows, Linux) are inherited from Finamp and have not been rebranded.
