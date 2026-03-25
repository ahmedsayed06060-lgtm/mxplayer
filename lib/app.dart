import 'package:flutter/material.dart';
import 'localization/generated/app_localizations.dart';

import 'core/themes/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/player/screens/player_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/splash/screens/splash_screen.dart';

class SmartPlayerProApp extends StatelessWidget {
  const SmartPlayerProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Player Pro',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      locale: null,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case HomeScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const HomeScreen(),
              settings: settings,
            );
          case PlayerScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const PlayerScreen(),
              settings: settings,
            );
          case SettingsScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const SettingsScreen(),
              settings: settings,
            );
          case SplashScreen.routeName:
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const SplashScreen(),
              settings: settings,
            );
        }
      },
      initialRoute: SplashScreen.routeName,
    );
  }
}


