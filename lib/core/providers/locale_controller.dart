import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(),
);

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en'));

  void setEnglish() => state = const Locale('en');
  void setArabic() => state = const Locale('ar');
  void toggle() => state = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
}
