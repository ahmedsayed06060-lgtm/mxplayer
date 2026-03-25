import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(),
);

final themeModeControllerProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(),
);

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en'));

  void setEnglish() => state = const Locale('en');
  void setArabic() => state = const Locale('ar');
  void toggle() => state = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
}

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.dark);

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
