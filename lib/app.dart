import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/locale_controller.dart';
import 'core/themes/app_theme.dart';
import 'features/downloads/screens/download_manager_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/player/screens/player_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'localization/generated/app_localizations.dart';

class SmartPlayerProApp extends ConsumerWidget {
  const SmartPlayerProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp(
      title: 'Smart Player Pro',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      locale: locale,
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
          case DownloadManagerScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const DownloadManagerScreen(),
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
