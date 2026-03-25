import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/locale_controller.dart';
import '../../../localization/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);
    final localeController = ref.read(localeControllerProvider.notifier);
    final themeMode = ref.watch(themeModeControllerProvider);
    final isDark = themeMode == ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Card(
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'en',
                groupValue: locale.languageCode,
                title: Text(l10n.english),
                onChanged: (_) => localeController.setEnglish(),
              ),
              RadioListTile<String>(
                value: 'ar',
                groupValue: locale.languageCode,
                title: Text(l10n.arabic),
                onChanged: (_) => localeController.setArabic(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            secondary: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            value: isDark,
            title: Text(l10n.theme),
            subtitle: Text(isDark ? l10n.themeDark : 'Light'),
            onChanged: (_) => ref.read(themeModeControllerProvider.notifier).toggle(),
          ),
        ),
      ],
    );
  }
}
