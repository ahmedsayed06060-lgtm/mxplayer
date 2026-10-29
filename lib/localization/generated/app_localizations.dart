import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Lightweight map based localization used by MX Player Pro.
///
/// Keeping the lookup table in a single place makes it trivial to add new
/// strings without running the l10n code generator.
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
      'appTitle': 'MX Player Pro',
      'splashTagline': 'The professional way to watch everything',
      'splashLoading': 'Loading library',
      'videos': 'Video',
      'folders': 'Folders',
      'iptv': 'Live TV',
      'favorites': 'Favorites',
      'settings': 'Settings',
      'downloads': 'Downloads',
      'downloadManager': 'Downloads',
      'downloadHistory': 'Download history',
      'downloadUrl': 'Video URL',
      'downloadHint': 'Paste a direct video link to save it offline',
      'downloadQueued': 'Queued',
      'downloadRunning': 'Downloading',
      'downloadPaused': 'Paused',
      'downloadComplete': 'Completed',
      'downloadFailed': 'Failed',
      'addDownload': 'Download',
      'openDownloads': 'Downloads',
      'downloadsEmpty': 'Nothing downloaded yet',
      'search': 'Search',
      'searchVideos': 'Search videos',
      'searchHint': 'Search by name, folder or format',
      'clear': 'Clear',
      'cancel': 'Cancel',
      'close': 'Close',
      'ok': 'OK',
      'done': 'Done',
      'save': 'Save',
      'delete': 'Delete',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'selectFolder': 'Add folder',
      'scanFailed': 'Scan failed',
      'noLibraryFound': 'No videos yet',
      'noLibraryFoundMessage': 'Add a folder or grant storage access so MX Player Pro can find your videos.',
      'noVideosFound': 'No videos found',
      'noFoldersFound': 'No folders found',
      'items': 'items',
      'allVideos': 'All videos',
      'all': 'All',
      'sortBy': 'Sort by',
      'sortRecentAdded': 'Date added',
      'sortRecentPlayed': 'Recently played',
      'sortName': 'Name',
      'sortSize': 'File size',
      'sortDuration': 'Duration',
      'listView': 'List view',
      'gridView': 'Grid view',
      'noResults': 'Nothing matches your search',
      'continueWatching': 'Continue watching',
      'recentlyPlayed': 'Recently played',
      'recent': 'Recent',
      'playlists': 'Playlists',
      'noPlaylists': 'No playlists yet',
      'createPlaylist': 'New playlist',
      'playlistName': 'Playlist name',
      'playlistEmpty': 'This playlist is empty',
      'playAll': 'Play all',
      'favorite': 'Add to favorites',
      'unfavorite': 'Remove from favorites',
      'favoritesOnly': 'Favorites',
      'noFavoritesYet': 'No favorites yet. Tap the heart on any video.',
      'noRecentYet': 'Videos you play show up here.',
      'play': 'Play',
      'pause': 'Pause',
      'resume': 'Resume',
      'player': 'Player',
      'nowPlaying': 'Now playing',
      'noMediaSelected': 'Nothing selected',
      'playbackSpeed': 'Speed',
      'fullscreen': 'Fullscreen',
      'exitFullscreen': 'Exit fullscreen',
      'lockControls': 'Lock',
      'unlockControls': 'Unlock',
      'playerLocked': 'Screen locked',
      'subtitles': 'Subtitle',
      'subtitlesOff': 'Off',
      'subtitleDelay': 'Delay',
      'subtitleSize': 'Size',
      'subtitleColor': 'Color',
      'autoDetectSubtitles': 'Auto detect',
      'loadSubtitle': 'Open subtitle file',
      'subtitleAuto': 'Automatic',
      'audio': 'Audio',
      'aspectRatio': 'Aspect',
      'aspectFit': 'Fit to screen',
      'aspectFill': 'Crop',
      'aspectStretch': 'Stretch',
      'aspectOriginal': '100%',
      'rotate': 'Rotate',
      'nightMode': 'Night mode',
      'next': 'Next',
      'previous': 'Previous',
      'rewind': 'Rewind',
      'forward': 'Forward',
      'volume': 'Volume',
      'brightness': 'Brightness',
      'zoom': 'Zoom',
      'resumePlayback': 'Resume',
      'restartFromBeginning': 'Start over',
      'autoPlayNext': 'Auto play next',
      'rememberPosition': 'Resume where I left',
      'playingNext': 'Up next',
      'videoInfo': 'Video info',
      'decoder': 'Decoder',
      'decoderHardware': 'HW+',
      'decoderSoftware': 'SW',
      'playback': 'Playback',
      'screenRotation': 'Screen orientation',
      'aspectLocked': 'Aspect locked',
      'playlistUrl': 'Playlist URL',
      'loadPlaylist': 'Load',
      'playlistLoaded': 'Playlist loaded',
      'invalidPlaylist': 'Could not load playlist',
      'channelSearch': 'Search channels',
      'channels': 'Channels',
      'noChannels': 'No channels yet. Paste an M3U link above.',
      'iptvHint': 'Add an M3U / M3U8 playlist link to stream channels',
      'groups': 'Groups',
      'language': 'Language',
      'english': 'English',
      'arabic': 'العربية',
      'theme': 'Theme',
      'themeDark': 'Dark',
      'themeLight': 'Light',
      'appearance': 'Appearance',
      'library': 'Library',
      'about': 'About',
      'version': 'Version',
      'appDescription': 'Powerful local video player with gesture controls, subtitles and live TV.',
      'storage': 'Storage',
      'folderPath': 'Folder path',
      'more': 'More',
      'scanAgain': 'Rescan library',
      'browseFolders': 'Browse folders',
      'supportedFormats': 'Supported formats',
      'openFolder': 'Open folder',
      'videosCount': 'videos',
      'resumeFrom': 'Resume from',
      'watched': 'watched',
      'now': 'now',
      'settingsHint': 'Tune the player to your taste',
      'encoding': 'Encoding',
      'resolution': 'Resolution',
      'fileSize': 'Size',
      'durationLabel': 'Duration',
      'pathLabel': 'Path',
      'noDescription': 'No description',
      'playerEngine': 'Player engine',
      'pickLocalMedia': 'Open file',
      'handoff': 'Continue on mini player',
      'expand': 'Expand',
      'collapse': 'Collapse',
      'shortcuts': 'Gestures',
      'gestureHint': 'Double tap sides to seek, drag up/down for volume and brightness, long press for 2x speed.',
      'speedNormal': 'Normal',
    },
    'ar': {
      'appTitle': 'MX Player Pro',
      'splashTagline': 'الطريقة الاحترافية لمشاهدة كل شيء',
      'splashLoading': 'جارٍ تحميل المكتبة',
      'videos': 'فيديو',
      'folders': 'المجلدات',
      'iptv': 'بث مباشر',
      'favorites': 'المفضلة',
      'settings': 'الإعدادات',
      'downloads': 'التنزيلات',
      'downloadManager': 'التنزيلات',
      'downloadHistory': 'سجل التنزيلات',
      'downloadUrl': 'رابط الفيديو',
      'downloadHint': 'ألصق رابط فيديو مباشر لحفظه للمشاهدة دون اتصال',
      'downloadQueued': 'في الانتظار',
      'downloadRunning': 'جارٍ التنزيل',
      'downloadPaused': 'متوقف مؤقتاً',
      'downloadComplete': 'مكتمل',
      'downloadFailed': 'فشل',
      'addDownload': 'تنزيل',
      'openDownloads': 'التنزيلات',
      'downloadsEmpty': 'لا توجد تنزيلات بعد',
      'search': 'بحث',
      'searchVideos': 'ابحث في الفيديوهات',
      'searchHint': 'ابحث بالاسم أو المجلد أو الصيغة',
      'clear': 'مسح',
      'cancel': 'إلغاء',
      'close': 'إغلاق',
      'ok': 'حسناً',
      'done': 'تم',
      'save': 'حفظ',
      'delete': 'حذف',
      'retry': 'إعادة المحاولة',
      'refresh': 'تحديث',
      'selectFolder': 'إضافة مجلد',
      'scanFailed': 'فشل الفحص',
      'noLibraryFound': 'لا توجد فيديوهات بعد',
      'noLibraryFoundMessage': 'أضف مجلداً أو امنح صلاحية التخزين ليعثر التطبيق على فيديوهاتك.',
      'noVideosFound': 'لم يتم العثور على فيديوهات',
      'noFoldersFound': 'لم يتم العثور على مجلدات',
      'items': 'عنصر',
      'allVideos': 'كل الفيديوهات',
      'all': 'الكل',
      'sortBy': 'ترتيب حسب',
      'sortRecentAdded': 'تاريخ الإضافة',
      'sortRecentPlayed': 'المشغّلة مؤخراً',
      'sortName': 'الاسم',
      'sortSize': 'الحجم',
      'sortDuration': 'المدة',
      'listView': 'قائمة',
      'gridView': 'شبكة',
      'noResults': 'لا يوجد ما يطابق بحثك',
      'continueWatching': 'متابعة المشاهدة',
      'recentlyPlayed': 'شوهدت مؤخراً',
      'recent': 'الأحدث',
      'playlists': 'قوائم التشغيل',
      'noPlaylists': 'لا توجد قوائم تشغيل',
      'createPlaylist': 'قائمة جديدة',
      'playlistName': 'اسم القائمة',
      'playlistEmpty': 'هذه القائمة فارغة',
      'playAll': 'تشغيل الكل',
      'favorite': 'إضافة إلى المفضلة',
      'unfavorite': 'إزالة من المفضلة',
      'favoritesOnly': 'المفضلة',
      'noFavoritesYet': 'لا توجد مفضلات. اضغط على القلب في أي فيديو.',
      'noRecentYet': 'ستظهر هنا الفيديوهات التي تشغلها.',
      'play': 'تشغيل',
      'pause': 'إيقاف مؤقت',
      'resume': 'استئناف',
      'player': 'المشغل',
      'nowPlaying': 'قيد التشغيل',
      'noMediaSelected': 'لم يتم اختيار شيء',
      'playbackSpeed': 'السرعة',
      'fullscreen': 'ملء الشاشة',
      'exitFullscreen': 'إنهاء ملء الشاشة',
      'lockControls': 'قفل',
      'unlockControls': 'فتح',
      'playerLocked': 'الشاشة مقفلة',
      'subtitles': 'الترجمة',
      'subtitlesOff': 'إيقاف',
      'subtitleDelay': 'التأخير',
      'subtitleSize': 'الحجم',
      'subtitleColor': 'اللون',
      'autoDetectSubtitles': 'كشف تلقائي',
      'loadSubtitle': 'فتح ملف ترجمة',
      'subtitleAuto': 'تلقائي',
      'audio': 'الصوت',
      'aspectRatio': 'الأبعاد',
      'aspectFit': 'ملاءمة الشاشة',
      'aspectFill': 'قص',
      'aspectStretch': 'تمديد',
      'aspectOriginal': '100%',
      'rotate': 'تدوير',
      'nightMode': 'الوضع الليلي',
      'next': 'التالي',
      'previous': 'السابق',
      'rewind': 'ترجيع',
      'forward': 'تقديم',
      'volume': 'الصوت',
      'brightness': 'السطوع',
      'zoom': 'التكبير',
      'resumePlayback': 'استئناف',
      'restartFromBeginning': 'من البداية',
      'autoPlayNext': 'تشغيل التالي تلقائياً',
      'rememberPosition': 'استئناف من حيث توقفت',
      'playingNext': 'التالي',
      'videoInfo': 'معلومات الفيديو',
      'decoder': 'فك الترميز',
      'decoderHardware': 'HW+',
      'decoderSoftware': 'SW',
      'playback': 'التشغيل',
      'screenRotation': 'اتجاه الشاشة',
      'aspectLocked': 'الأبعاد مقفلة',
      'playlistUrl': 'رابط قائمة التشغيل',
      'loadPlaylist': 'تحميل',
      'playlistLoaded': 'تم تحميل القائمة',
      'invalidPlaylist': 'تعذر تحميل القائمة',
      'channelSearch': 'بحث القنوات',
      'channels': 'القنوات',
      'noChannels': 'لا توجد قنوات. ألصق رابط M3U بالأعلى.',
      'iptvHint': 'أضف رابط M3U أو M3U8 لبث القنوات',
      'groups': 'المجموعات',
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'theme': 'المظهر',
      'themeDark': 'داكن',
      'themeLight': 'فاتح',
      'appearance': 'المظهر',
      'library': 'المكتبة',
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'appDescription': 'مشغل فيديو قوي مع إيماءات وترجمة وبث مباشر.',
      'storage': 'التخزين',
      'folderPath': 'مسار المجلد',
      'more': 'المزيد',
      'scanAgain': 'إعادة فحص المكتبة',
      'browseFolders': 'تصفح المجلدات',
      'supportedFormats': 'الصيغ المدعومة',
      'openFolder': 'فتح المجلد',
      'videosCount': 'فيديو',
      'resumeFrom': 'المتابعة من',
      'watched': 'تمت مشاهدته',
      'now': 'الآن',
      'settingsHint': 'اضبط المشغل حسب ذوقك',
      'encoding': 'الترميز',
      'resolution': 'الدقة',
      'fileSize': 'الحجم',
      'durationLabel': 'المدة',
      'pathLabel': 'المسار',
      'noDescription': 'لا يوجد وصف',
      'playerEngine': 'محرك التشغيل',
      'pickLocalMedia': 'فتح ملف',
      'handoff': 'المتابعة في المشغل المصغر',
      'expand': 'توسيع',
      'collapse': 'تصغير',
      'shortcuts': 'الإيماءات',
      'gestureHint': 'اضغط مرتين على الجانبين للتقديم، واسحب لأعلى وأسفل للصوت والسطوع، واضغط مطولاً لسرعة 2x.',
      'speedNormal': 'عادي',
    },
  };

  String _text(String key) {
    return _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
  }

  String get appTitle => _text('appTitle');
  String get splashTagline => _text('splashTagline');
  String get splashLoading => _text('splashLoading');
  String get videos => _text('videos');
  String get folders => _text('folders');
  String get iptv => _text('iptv');
  String get favorites => _text('favorites');
  String get settings => _text('settings');
  String get downloads => _text('downloads');
  String get downloadManager => _text('downloadManager');
  String get downloadHistory => _text('downloadHistory');
  String get downloadUrl => _text('downloadUrl');
  String get downloadHint => _text('downloadHint');
  String get downloadQueued => _text('downloadQueued');
  String get downloadRunning => _text('downloadRunning');
  String get downloadPaused => _text('downloadPaused');
  String get downloadComplete => _text('downloadComplete');
  String get downloadFailed => _text('downloadFailed');
  String get addDownload => _text('addDownload');
  String get openDownloads => _text('openDownloads');
  String get downloadsEmpty => _text('downloadsEmpty');
  String get search => _text('search');
  String get searchVideos => _text('searchVideos');
  String get searchHint => _text('searchHint');
  String get clear => _text('clear');
  String get cancel => _text('cancel');
  String get close => _text('close');
  String get ok => _text('ok');
  String get done => _text('done');
  String get save => _text('save');
  String get delete => _text('delete');
  String get retry => _text('retry');
  String get refresh => _text('refresh');
  String get selectFolder => _text('selectFolder');
  String get scanFailed => _text('scanFailed');
  String get noLibraryFound => _text('noLibraryFound');
  String get noLibraryFoundMessage => _text('noLibraryFoundMessage');
  String get noVideosFound => _text('noVideosFound');
  String get noFoldersFound => _text('noFoldersFound');
  String get items => _text('items');
  String get allVideos => _text('allVideos');
  String get all => _text('all');
  String get sortBy => _text('sortBy');
  String get sortRecentAdded => _text('sortRecentAdded');
  String get sortRecentPlayed => _text('sortRecentPlayed');
  String get sortName => _text('sortName');
  String get sortSize => _text('sortSize');
  String get sortDuration => _text('sortDuration');
  String get listView => _text('listView');
  String get gridView => _text('gridView');
  String get noResults => _text('noResults');
  String get continueWatching => _text('continueWatching');
  String get recentlyPlayed => _text('recentlyPlayed');
  String get recent => _text('recent');
  String get playlists => _text('playlists');
  String get noPlaylists => _text('noPlaylists');
  String get createPlaylist => _text('createPlaylist');
  String get playlistName => _text('playlistName');
  String get playlistEmpty => _text('playlistEmpty');
  String get playAll => _text('playAll');
  String get favorite => _text('favorite');
  String get unfavorite => _text('unfavorite');
  String get favoritesOnly => _text('favoritesOnly');
  String get noFavoritesYet => _text('noFavoritesYet');
  String get noRecentYet => _text('noRecentYet');
  String get play => _text('play');
  String get pause => _text('pause');
  String get resume => _text('resume');
  String get player => _text('player');
  String get nowPlaying => _text('nowPlaying');
  String get noMediaSelected => _text('noMediaSelected');
  String get playbackSpeed => _text('playbackSpeed');
  String get fullscreen => _text('fullscreen');
  String get exitFullscreen => _text('exitFullscreen');
  String get lockControls => _text('lockControls');
  String get unlockControls => _text('unlockControls');
  String get playerLocked => _text('playerLocked');
  String get subtitles => _text('subtitles');
  String get subtitlesOff => _text('subtitlesOff');
  String get subtitleDelay => _text('subtitleDelay');
  String get subtitleSize => _text('subtitleSize');
  String get subtitleColor => _text('subtitleColor');
  String get autoDetectSubtitles => _text('autoDetectSubtitles');
  String get loadSubtitle => _text('loadSubtitle');
  String get subtitleAuto => _text('subtitleAuto');
  String get audio => _text('audio');
  String get aspectRatio => _text('aspectRatio');
  String get aspectFit => _text('aspectFit');
  String get aspectFill => _text('aspectFill');
  String get aspectStretch => _text('aspectStretch');
  String get aspectOriginal => _text('aspectOriginal');
  String get rotate => _text('rotate');
  String get nightMode => _text('nightMode');
  String get next => _text('next');
  String get previous => _text('previous');
  String get rewind => _text('rewind');
  String get forward => _text('forward');
  String get volume => _text('volume');
  String get brightness => _text('brightness');
  String get zoom => _text('zoom');
  String get resumePlayback => _text('resumePlayback');
  String get restartFromBeginning => _text('restartFromBeginning');
  String get autoPlayNext => _text('autoPlayNext');
  String get rememberPosition => _text('rememberPosition');
  String get playingNext => _text('playingNext');
  String get videoInfo => _text('videoInfo');
  String get decoder => _text('decoder');
  String get decoderHardware => _text('decoderHardware');
  String get decoderSoftware => _text('decoderSoftware');
  String get playback => _text('playback');
  String get screenRotation => _text('screenRotation');
  String get aspectLocked => _text('aspectLocked');
  String get playlistUrl => _text('playlistUrl');
  String get loadPlaylist => _text('loadPlaylist');
  String get playlistLoaded => _text('playlistLoaded');
  String get invalidPlaylist => _text('invalidPlaylist');
  String get channelSearch => _text('channelSearch');
  String get channels => _text('channels');
  String get noChannels => _text('noChannels');
  String get iptvHint => _text('iptvHint');
  String get groups => _text('groups');
  String get language => _text('language');
  String get english => _text('english');
  String get arabic => _text('arabic');
  String get theme => _text('theme');
  String get themeDark => _text('themeDark');
  String get themeLight => _text('themeLight');
  String get appearance => _text('appearance');
  String get library => _text('library');
  String get about => _text('about');
  String get version => _text('version');
  String get appDescription => _text('appDescription');
  String get storage => _text('storage');
  String get folderPath => _text('folderPath');
  String get more => _text('more');
  String get scanAgain => _text('scanAgain');
  String get browseFolders => _text('browseFolders');
  String get supportedFormats => _text('supportedFormats');
  String get openFolder => _text('openFolder');
  String get videosCount => _text('videosCount');
  String get resumeFrom => _text('resumeFrom');
  String get watched => _text('watched');
  String get now => _text('now');
  String get settingsHint => _text('settingsHint');
  String get encoding => _text('encoding');
  String get resolution => _text('resolution');
  String get fileSize => _text('fileSize');
  String get durationLabel => _text('durationLabel');
  String get pathLabel => _text('pathLabel');
  String get noDescription => _text('noDescription');
  String get playerEngine => _text('playerEngine');
  String get pickLocalMedia => _text('pickLocalMedia');
  String get handoff => _text('handoff');
  String get expand => _text('expand');
  String get collapse => _text('collapse');
  String get shortcuts => _text('shortcuts');
  String get gestureHint => _text('gestureHint');
  String get speedNormal => _text('speedNormal');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => const <String>['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
