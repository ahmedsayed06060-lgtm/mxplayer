# MX Player Pro (Flutter)

A polished, **MX Player Pro style** local video player built with Flutter: gesture driven
playback, subtitles, playlist handling, live TV (M3U), downloads and a full MX-inspired
dark UI.

## Highlights

### Look & feel
- MX Player palette: near-black surfaces (`#0B0C0E`), signature green accent (`#3DDC84`),
  rounded squircle logo and MX wordmark.
- Animated splash screen, custom top bar with inline search, custom bottom navigation
  (icon + label, green selected state) and a side rail on wide desktop windows.
- Light theme included; both themes share the same design tokens.

### Video library
- Continue watching / recent rail with thumbnails, remaining time and progress bars.
- List and grid layouts, sort by date / recently played / name / size / duration.
- Format chips (All, MP4, MKV, AVI, WEBM) and a favorites filter.
- Search by title, folder or container, plus folder browser with per-folder counts.
- Each thumbnail shows resolution quality (4K/FHD/HD/SD), duration, watch progress and a
  favorite marker. Long press / ⋮ opens the MX style action sheet (play, favorite,
  playlists, video info).

### Player
- Auto-hiding overlay controls with top bar (title, queue position, favorite, more).
- Build inspired controls: previous / rewind 10 / play-pause / forward 10 / next, a thin
  green seek bar and a bottom action row (speed, subtitle, aspect, lock, rotate).
- Gestures: tap to show/hide controls, double tap sides to seek ±10s, vertical drag for
  volume (right) and brightness (left) with HUD, horizontal drag for scrub preview,
  long press for temporary 2x playback.
- Aspect modes (fit, crop, stretch, 100%), night mode, screen lock, subtitle sheet
  (auto detect, file picker, delay, size, color), playback speed sheet, video info.
- Minimising (↓) keeps playback alive in the mini player instead of stopping it.

### Live TV, downloads, favorites & settings
- M3U/M3U8 playlist loader with group chips, channel search and favorites.
- Download manager with status colours, progress bars and inline playback of finished
  downloads (platform HTTP fallback on desktop).
- Favorites screen with favorites, playlists and recent rows.
- Settings: appearance (theme/language/night mode), playback preferences
  (default speed, auto play next, resume position, keep screen on, gesture help), library
  actions and an about section.

## Architecture

```
lib/
  core/            theme tokens, shared MX widgets, providers, constants
  data/            models, sqflite persistence, repositories
  features/
    home/          app shell, top bar, navigation, mini player
    library/       video list, grids, folders, thumbnails, action sheets
    player/        player controller, surface, overlay UI
    iptv/          live TV
    downloads/     download manager
    favorites/     favorites + playlists + recent
    settings/      settings screen and playback preferences
    splash/        animated splash
  localization/    ARB files + generated AppLocalizations (EN / AR)
```

Persistence uses `sqflite`; every database call degrades gracefully on desktop platforms
that do not support it, so the app remains usable.

## Build

```bash
flutter pub get          # also regenerates localizations (generate: true)
flutter gen-l10n         # optional, explicit localization generation
flutter run -d windows
flutter build windows --release
```

CI: `.github/workflows/build-windows.yml` runs `flutter analyze` and builds the Windows
release artifact on every push to `main` (or manual dispatch).
