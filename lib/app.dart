import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
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
    final Locale locale = ref.watch(localeControllerProvider);
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      scrollBehavior: const _MxScrollBehavior(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case HomeScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const HomeScreen(),
              settings: settings,
            );
          case PlayerScreen.routeName:
            return PageRouteBuilder<void>(
              settings: settings,
              opaque: true,
              transitionDuration: const Duration(milliseconds: 220),
              reverseTransitionDuration: const Duration(milliseconds: 180),
              pageBuilder: (_, __, ___) => const PlayerScreen(),
              transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                return FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  child: child,
                );
              },
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

/// Allows mouse dragging on desktop (scroll bars + wheel still work).
class _MxScrollBehavior extends MaterialScrollBehavior {
  const _MxScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
