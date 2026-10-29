class AppConstants {
  const AppConstants._();

  static const String appName = 'MX Player Pro';
  static const String appShortName = 'MX';
  static const String version = '1.62.0';
  static const String buildNumber = '1';
  static const String playerEngine = 'MX Engine';
  static const String databaseFileName = 'smart_player_pro.db';

  static const List<String> videoExtensions = <String>[
    'mp4',
    'mkv',
    'avi',
    'mov',
    'flv',
    'wmv',
    'webm',
    'm4v',
    'ts',
    '3gp',
  ];

  static const List<double> playbackSpeeds = <double>[
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];
}
