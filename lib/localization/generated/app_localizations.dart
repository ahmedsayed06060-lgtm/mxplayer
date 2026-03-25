import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appTitle': 'Smart Player Pro',
      'videos': 'Videos',
      'folders': 'Folders',
      'favorites': 'Favorites',
      'settings': 'Settings',
      'recentlyPlayed': 'Recently Played',
      'player': 'Player',
      'language': 'Language',
      'theme': 'Theme',
      'themeDark': 'Dark',
      'languagePlaceholder': 'Switch instantly between English and Arabic.',
      'playerPlaceholderTitle': 'Player engine ready',
      'playerPlaceholderBody': 'Use gestures, subtitles, playback speed, and fullscreen controls.',
      'splashTagline': 'Professional video playback for local media, IPTV, and downloads.',
      'allVideos': 'All Videos',
      'storage': 'Storage',
      'selectFolder': 'Select Folder',
      'refresh': 'Refresh',
      'scanFailed': 'Scan failed',
      'tryAgain': 'Try again',
      'noLibraryFound': 'No video library found',
      'noLibraryFoundMessage': 'Choose a folder or grant storage access to scan your video collection.',
      'noVideosFound': 'No videos found in the selected locations.',
      'noFoldersFound': 'No folders found.',
      'items': 'items',
      'iptv': 'IPTV',
      'downloads': 'Downloads',
      'miniPlayer': 'Mini player',
      'play': 'Play',
      'pause': 'Pause',
      'resume': 'Resume',
      'cancel': 'Cancel',
      'close': 'Close',
      'playbackSpeed': 'Playback Speed',
      'fullscreen': 'Fullscreen',
      'lockControls': 'Lock controls',
      'unlockControls': 'Unlock controls',
      'subtitles': 'Subtitles',
      'subtitleDelay': 'Subtitle Delay',
      'subtitleSize': 'Subtitle Size',
      'subtitleColor': 'Subtitle Color',
      'autoDetectSubtitles': 'Auto-detect subtitles',
      'loadSubtitle': 'Load subtitle file',
      'noMediaSelected': 'No media selected',
      'openPlayer': 'Open player',
      'volume': 'Volume',
      'brightness': 'Brightness',
      'zoom': 'Zoom',
      'rewind': 'Rewind',
      'forward': 'Forward',
      'recent': 'Recent',
      'favorite': 'Favorite',
      'unfavorite': 'Remove favorite',
      'loadPlaylist': 'Load Playlist',
      'playlistUrl': 'Playlist URL',
      'channelSearch': 'Search channels',
      'channels': 'Channels',
      'noChannels': 'No channels loaded yet.',
      'favoritesOnly': 'Favorites only',
      'addDownload': 'Add download',
      'downloadUrl': 'Video URL',
      'downloadHistory': 'Download history',
      'downloadManager': 'Download Manager',
      'downloadQueued': 'Queued',
      'downloadRunning': 'Downloading',
      'downloadPaused': 'Paused',
      'downloadComplete': 'Completed',
      'downloadFailed': 'Failed',
      'enterUrl': 'Enter a URL',
      'openDownloads': 'Open downloads',
      'useSystemTheme': 'Dark Material 3 theme',
      'arabic': 'Arabic',
      'english': 'English',
      'subtitleNone': 'No subtitles',
      'subtitleAuto': 'Automatic',
      'openVideo': 'Open video',
      'folderPath': 'Folder path',
      'playlistLoaded': 'Playlist loaded',
      'invalidPlaylist': 'Unable to load playlist',
      'search': 'Search',
      'clear': 'Clear',
      'noFavoritesYet': 'No favorites yet.',
      'noRecentYet': 'Nothing played yet.',
      'downloadHint': 'Paste a direct video URL to download it for offline playback.',
      'iptvHint': 'Add an M3U or M3U8 playlist URL to stream IPTV channels.',
      'playerLocked': 'Player locked. Tap the lock to unlock controls.',
      'pickLocalMedia': 'Pick local media',
    },
    'ar': {
      'appTitle': '????? ????? ???',
      'videos': '??????????',
      'folders': '????????',
      'favorites': '???????',
      'settings': '?????????',
      'recentlyPlayed': '??????? ??????',
      'player': '??????',
      'language': '?????',
      'theme': '?????',
      'themeDark': '????',
      'languagePlaceholder': '????? ??????? ????? ??? ??????? ???????????.',
      'playerPlaceholderTitle': '???? ??????? ????',
      'playerPlaceholderBody': '?????? ????????? ???????? ????? ??????? ???? ??? ??????.',
      'splashTagline': '????? ??????? ?????????? ??????? ?IPTV ??????????.',
      'allVideos': '?? ??????????',
      'storage': '???????',
      'selectFolder': '?????? ????',
      'refresh': '?????',
      'scanFailed': '??? ?????',
      'tryAgain': '????? ????????',
      'noLibraryFound': '?? ??? ?????? ??? ????? ?????',
      'noLibraryFoundMessage': '???? ?????? ?? ???? ?????? ??????? ???? ????? ??????? ?????? ??.',
      'noVideosFound': '?? ??? ?????? ??? ???????? ?? ??????? ???????.',
      'noFoldersFound': '?? ??? ?????? ??? ??????.',
      'items': '????',
      'iptv': '?? ?? ?? ??',
      'downloads': '?????????',
      'miniPlayer': '?????? ??????',
      'play': '?????',
      'pause': '????? ????',
      'resume': '???????',
      'cancel': '?????',
      'close': '?????',
      'playbackSpeed': '???? ???????',
      'fullscreen': '??? ??????',
      'lockControls': '??? ??????',
      'unlockControls': '????? ??? ??????',
      'subtitles': '???????',
      'subtitleDelay': '????? ???????',
      'subtitleSize': '??? ???????',
      'subtitleColor': '??? ???????',
      'autoDetectSubtitles': '??? ??????? ????????',
      'loadSubtitle': '????? ??? ?????',
      'noMediaSelected': '?? ??? ?????? ?????',
      'openPlayer': '??? ??????',
      'volume': '?????',
      'brightness': '??????',
      'zoom': '???????',
      'rewind': '?????',
      'forward': '?????',
      'recent': '???????',
      'favorite': '?????',
      'unfavorite': '????? ?? ???????',
      'loadPlaylist': '????? ???????',
      'playlistUrl': '???? ???????',
      'channelSearch': '????? ?? ???????',
      'channels': '???????',
      'noChannels': '?? ??? ????? ????? ???.',
      'favoritesOnly': '??????? ???',
      'addDownload': '????? ?????',
      'downloadUrl': '???? ???????',
      'downloadHistory': '??? ???????',
      'downloadManager': '???? ???????',
      'downloadQueued': '?? ????????',
      'downloadRunning': '???? ???????',
      'downloadPaused': '?????',
      'downloadComplete': '?????',
      'downloadFailed': '???',
      'enterUrl': '???? ??????',
      'openDownloads': '??? ?????????',
      'useSystemTheme': '??? Material 3 ???????',
      'arabic': '???????',
      'english': '??????????',
      'subtitleNone': '???? ?????',
      'subtitleAuto': '??????',
      'openVideo': '??? ???????',
      'folderPath': '???? ??????',
      'playlistLoaded': '?? ????? ???????',
      'invalidPlaylist': '???? ????? ???????',
      'search': '???',
      'clear': '???',
      'noFavoritesYet': '?? ???? ????? ????? ???.',
      'noRecentYet': '?? ??? ????? ?? ??? ???.',
      'downloadHint': '???? ???? ????? ????? ??????? ??????? ??? ?????.',
      'iptvHint': '??? ???? ????? M3U ?? M3U8 ??? ????? IPTV.',
      'playerLocked': '?????? ????. ???? ??? ????? ?????? ?????.',
      'pickLocalMedia': '?????? ????? ?????',
    },
  };

  String _text(String key) => _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  String get appTitle => _text('appTitle');
  String get videos => _text('videos');
  String get folders => _text('folders');
  String get favorites => _text('favorites');
  String get settings => _text('settings');
  String get recentlyPlayed => _text('recentlyPlayed');
  String get player => _text('player');
  String get language => _text('language');
  String get theme => _text('theme');
  String get themeDark => _text('themeDark');
  String get languagePlaceholder => _text('languagePlaceholder');
  String get playerPlaceholderTitle => _text('playerPlaceholderTitle');
  String get playerPlaceholderBody => _text('playerPlaceholderBody');
  String get splashTagline => _text('splashTagline');
  String get allVideos => _text('allVideos');
  String get storage => _text('storage');
  String get selectFolder => _text('selectFolder');
  String get refresh => _text('refresh');
  String get scanFailed => _text('scanFailed');
  String get tryAgain => _text('tryAgain');
  String get noLibraryFound => _text('noLibraryFound');
  String get noLibraryFoundMessage => _text('noLibraryFoundMessage');
  String get noVideosFound => _text('noVideosFound');
  String get noFoldersFound => _text('noFoldersFound');
  String get items => _text('items');
  String get iptv => _text('iptv');
  String get downloads => _text('downloads');
  String get miniPlayer => _text('miniPlayer');
  String get play => _text('play');
  String get pause => _text('pause');
  String get resume => _text('resume');
  String get cancel => _text('cancel');
  String get close => _text('close');
  String get playbackSpeed => _text('playbackSpeed');
  String get fullscreen => _text('fullscreen');
  String get lockControls => _text('lockControls');
  String get unlockControls => _text('unlockControls');
  String get subtitles => _text('subtitles');
  String get subtitleDelay => _text('subtitleDelay');
  String get subtitleSize => _text('subtitleSize');
  String get subtitleColor => _text('subtitleColor');
  String get autoDetectSubtitles => _text('autoDetectSubtitles');
  String get loadSubtitle => _text('loadSubtitle');
  String get noMediaSelected => _text('noMediaSelected');
  String get openPlayer => _text('openPlayer');
  String get volume => _text('volume');
  String get brightness => _text('brightness');
  String get zoom => _text('zoom');
  String get rewind => _text('rewind');
  String get forward => _text('forward');
  String get recent => _text('recent');
  String get favorite => _text('favorite');
  String get unfavorite => _text('unfavorite');
  String get loadPlaylist => _text('loadPlaylist');
  String get playlistUrl => _text('playlistUrl');
  String get channelSearch => _text('channelSearch');
  String get channels => _text('channels');
  String get noChannels => _text('noChannels');
  String get favoritesOnly => _text('favoritesOnly');
  String get addDownload => _text('addDownload');
  String get downloadUrl => _text('downloadUrl');
  String get downloadHistory => _text('downloadHistory');
  String get downloadManager => _text('downloadManager');
  String get downloadQueued => _text('downloadQueued');
  String get downloadRunning => _text('downloadRunning');
  String get downloadPaused => _text('downloadPaused');
  String get downloadComplete => _text('downloadComplete');
  String get downloadFailed => _text('downloadFailed');
  String get enterUrl => _text('enterUrl');
  String get openDownloads => _text('openDownloads');
  String get useSystemTheme => _text('useSystemTheme');
  String get arabic => _text('arabic');
  String get english => _text('english');
  String get subtitleNone => _text('subtitleNone');
  String get subtitleAuto => _text('subtitleAuto');
  String get openVideo => _text('openVideo');
  String get folderPath => _text('folderPath');
  String get playlistLoaded => _text('playlistLoaded');
  String get invalidPlaylist => _text('invalidPlaylist');
  String get search => _text('search');
  String get clear => _text('clear');
  String get noFavoritesYet => _text('noFavoritesYet');
  String get noRecentYet => _text('noRecentYet');
  String get downloadHint => _text('downloadHint');
  String get iptvHint => _text('iptvHint');
  String get playerLocked => _text('playerLocked');
  String get pickLocalMedia => _text('pickLocalMedia');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

