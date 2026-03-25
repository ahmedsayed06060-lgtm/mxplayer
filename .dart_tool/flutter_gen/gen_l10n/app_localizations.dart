import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Player Pro'**
  String get appTitle;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Switch instantly between English and Arabic.'**
  String get languagePlaceholder;

  /// No description provided for @playerPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Player engine ready'**
  String get playerPlaceholderTitle;

  /// No description provided for @playerPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Use gestures, subtitles, playback speed, and fullscreen controls.'**
  String get playerPlaceholderBody;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Professional video playback for local media, IPTV, and downloads.'**
  String get splashTagline;

  /// No description provided for @allVideos.
  ///
  /// In en, this message translates to:
  /// **'All Videos'**
  String get allVideos;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Folder'**
  String get selectFolder;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed'**
  String get scanFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noLibraryFound.
  ///
  /// In en, this message translates to:
  /// **'No video library found'**
  String get noLibraryFound;

  /// No description provided for @noLibraryFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder or grant storage access to scan your video collection.'**
  String get noLibraryFoundMessage;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found in the selected locations.'**
  String get noVideosFound;

  /// No description provided for @noFoldersFound.
  ///
  /// In en, this message translates to:
  /// **'No folders found.'**
  String get noFoldersFound;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @iptv.
  ///
  /// In en, this message translates to:
  /// **'IPTV'**
  String get iptv;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @miniPlayer.
  ///
  /// In en, this message translates to:
  /// **'Mini player'**
  String get miniPlayer;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get playbackSpeed;

  /// No description provided for @fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// No description provided for @lockControls.
  ///
  /// In en, this message translates to:
  /// **'Lock controls'**
  String get lockControls;

  /// No description provided for @unlockControls.
  ///
  /// In en, this message translates to:
  /// **'Unlock controls'**
  String get unlockControls;

  /// No description provided for @subtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitles;

  /// No description provided for @subtitleDelay.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Delay'**
  String get subtitleDelay;

  /// No description provided for @subtitleSize.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Size'**
  String get subtitleSize;

  /// No description provided for @subtitleColor.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Color'**
  String get subtitleColor;

  /// No description provided for @autoDetectSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect subtitles'**
  String get autoDetectSubtitles;

  /// No description provided for @loadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load subtitle file'**
  String get loadSubtitle;

  /// No description provided for @noMediaSelected.
  ///
  /// In en, this message translates to:
  /// **'No media selected'**
  String get noMediaSelected;

  /// No description provided for @openPlayer.
  ///
  /// In en, this message translates to:
  /// **'Open player'**
  String get openPlayer;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @zoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get zoom;

  /// No description provided for @rewind.
  ///
  /// In en, this message translates to:
  /// **'Rewind'**
  String get rewind;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get unfavorite;

  /// No description provided for @loadPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Load Playlist'**
  String get loadPlaylist;

  /// No description provided for @playlistUrl.
  ///
  /// In en, this message translates to:
  /// **'Playlist URL'**
  String get playlistUrl;

  /// No description provided for @channelSearch.
  ///
  /// In en, this message translates to:
  /// **'Search channels'**
  String get channelSearch;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @noChannels.
  ///
  /// In en, this message translates to:
  /// **'No channels loaded yet.'**
  String get noChannels;

  /// No description provided for @favoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get favoritesOnly;

  /// No description provided for @addDownload.
  ///
  /// In en, this message translates to:
  /// **'Add download'**
  String get addDownload;

  /// No description provided for @downloadUrl.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get downloadUrl;

  /// No description provided for @downloadHistory.
  ///
  /// In en, this message translates to:
  /// **'Download history'**
  String get downloadHistory;

  /// No description provided for @downloadManager.
  ///
  /// In en, this message translates to:
  /// **'Download Manager'**
  String get downloadManager;

  /// No description provided for @downloadQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get downloadQueued;

  /// No description provided for @downloadRunning.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloadRunning;

  /// No description provided for @downloadPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get downloadPaused;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get downloadComplete;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get downloadFailed;

  /// No description provided for @enterUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a URL'**
  String get enterUrl;

  /// No description provided for @openDownloads.
  ///
  /// In en, this message translates to:
  /// **'Open downloads'**
  String get openDownloads;

  /// No description provided for @useSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Material 3 theme'**
  String get useSystemTheme;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @subtitleNone.
  ///
  /// In en, this message translates to:
  /// **'No subtitles'**
  String get subtitleNone;

  /// No description provided for @subtitleAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get subtitleAuto;

  /// No description provided for @openVideo.
  ///
  /// In en, this message translates to:
  /// **'Open video'**
  String get openVideo;

  /// No description provided for @folderPath.
  ///
  /// In en, this message translates to:
  /// **'Folder path'**
  String get folderPath;

  /// No description provided for @playlistLoaded.
  ///
  /// In en, this message translates to:
  /// **'Playlist loaded'**
  String get playlistLoaded;

  /// No description provided for @invalidPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Unable to load playlist'**
  String get invalidPlaylist;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.'**
  String get noFavoritesYet;

  /// No description provided for @noRecentYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing played yet.'**
  String get noRecentYet;

  /// No description provided for @downloadHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a direct video URL to download it for offline playback.'**
  String get downloadHint;

  /// No description provided for @iptvHint.
  ///
  /// In en, this message translates to:
  /// **'Add an M3U or M3U8 playlist URL to stream IPTV channels.'**
  String get iptvHint;

  /// No description provided for @playerLocked.
  ///
  /// In en, this message translates to:
  /// **'Player locked. Tap the lock to unlock controls.'**
  String get playerLocked;

  /// No description provided for @pickLocalMedia.
  ///
  /// In en, this message translates to:
  /// **'Pick local media'**
  String get pickLocalMedia;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
