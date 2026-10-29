import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/locale_controller.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../data/models/library_snapshot.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../downloads/screens/download_manager_screen.dart';
import '../../library/controllers/library_controller.dart';
import '../controllers/playback_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale locale = ref.watch(localeControllerProvider);
    final LocaleController localeController = ref.read(localeControllerProvider.notifier);
    final ThemeMode themeMode = ref.watch(themeModeControllerProvider);
    final ThemeModeController themeController = ref.read(themeModeControllerProvider.notifier);
    final PlaybackPreferences prefs = ref.watch(playbackPreferencesProvider);
    final PlaybackPreferencesController prefsController =
        ref.read(playbackPreferencesProvider.notifier);
    final LibrarySnapshot? snapshot = ref.watch(libraryControllerProvider).valueOrNull;
    final bool isDark = themeMode == ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 140),
      children: <Widget>[
        _BrandHeader(snapshot: snapshot),
        MxSettingsGroup(
          title: l10n.appearance,
          children: <Widget>[
            MxSettingsTile(
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              title: l10n.theme,
              subtitle: isDark ? l10n.themeDark : l10n.themeLight,
              trailing: Switch(
                value: isDark,
                onChanged: (_) => themeController.toggle(),
              ),
            ),
            MxSettingsTile(
              icon: Icons.translate_rounded,
              title: l10n.language,
              subtitle: locale.languageCode == 'ar' ? l10n.arabic : l10n.english,
              onTap: () => _showLanguageSheet(context, locale, localeController),
            ),
            MxSettingsTile(
              icon: Icons.nightlight_round,
              title: l10n.nightMode,
              trailing: Switch(
                value: prefs.nightMode,
                onChanged: prefsController.setNightMode,
              ),
            ),
          ],
        ),
        MxSettingsGroup(
          title: l10n.playback,
          children: <Widget>[
            MxSettingsTile(
              icon: Icons.speed_rounded,
              title: l10n.playbackSpeed,
              subtitle: prefs.defaultSpeed == 1
                  ? '1x • ${l10n.speedNormal}'
                  : '${prefs.defaultSpeed}x',
              onTap: () => _showSpeedSheet(context, prefs, prefsController),
            ),
            MxSettingsTile(
              icon: Icons.skip_next_rounded,
              title: l10n.autoPlayNext,
              trailing: Switch(
                value: prefs.autoPlayNext,
                onChanged: prefsController.setAutoPlayNext,
              ),
            ),
            MxSettingsTile(
              icon: Icons.restore_rounded,
              title: l10n.rememberPosition,
              trailing: Switch(
                value: prefs.rememberPosition,
                onChanged: prefsController.setRememberPosition,
              ),
            ),
            MxSettingsTile(
              icon: Icons.screen_lock_landscape_rounded,
              title: l10n.screenRotation,
              trailing: Switch(
                value: prefs.keepScreenOn,
                onChanged: prefsController.setKeepScreenOn,
              ),
            ),
            MxSettingsTile(
              icon: Icons.touch_app_rounded,
              title: l10n.shortcuts,
              subtitle: l10n.gestureHint,
              onTap: () => _showGestureDialog(context, l10n),
            ),
          ],
        ),
        MxSettingsGroup(
          title: l10n.library,
          children: <Widget>[
            MxSettingsTile(
              icon: Icons.create_new_folder_outlined,
              title: l10n.selectFolder,
              subtitle: snapshot?.scanRoots.isNotEmpty == true
                  ? snapshot!.scanRoots.join(' • ')
                  : l10n.noLibraryFound,
              onTap: () => ref.read(libraryControllerProvider.notifier).pickAndScanDirectory(),
            ),
            MxSettingsTile(
              icon: Icons.refresh_rounded,
              title: l10n.scanAgain,
              subtitle: snapshot == null
                  ? null
                  : '${snapshot.totalVideos} ${l10n.videosCount} • '
                      '${Formatters.fileSize(snapshot.videos.fold<int>(0, (int sum, item) => sum + item.fileSizeBytes))}',
              onTap: () => ref.read(libraryControllerProvider.notifier).refresh(),
            ),
            MxSettingsTile(
              icon: Icons.download_rounded,
              title: l10n.downloadManager,
              onTap: () => Navigator.of(context).pushNamed(DownloadManagerScreen.routeName),
            ),
          ],
        ),
        MxSettingsGroup(
          title: l10n.about,
          children: <Widget>[
            MxSettingsTile(
              icon: Icons.movie_filter_rounded,
              title: AppConstants.appName,
              subtitle: l10n.appDescription,
              trailing: const SizedBox.shrink(),
            ),
            MxSettingsTile(
              icon: Icons.info_outline_rounded,
              title: l10n.version,
              subtitle: '${AppConstants.version} (${AppConstants.buildNumber})',
              trailing: const SizedBox.shrink(),
            ),
            MxSettingsTile(
              icon: Icons.memory_rounded,
              title: l10n.playerEngine,
              subtitle: '${AppConstants.playerEngine} • media_kit',
              trailing: const SizedBox.shrink(),
            ),
            MxSettingsTile(
              icon: Icons.video_settings_rounded,
              title: l10n.supportedFormats,
              subtitle: AppConstants.videoExtensions.map((String e) => e.toUpperCase()).join(', '),
              trailing: const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Center(
          child: Column(
            children: <Widget>[
              const MxLogo(size: 34, showShadow: false),
              const SizedBox(height: 8),
              Text(
                '${l10n.appTitle} • v${AppConstants.version}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    Locale locale,
    LocaleController controller,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxSheetHeader(title: l10n.language),
              ListTile(
                leading: Icon(
                  locale.languageCode == 'en'
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: locale.languageCode == 'en' ? MxColors.brand : null,
                  size: 20,
                ),
                title: Text(l10n.english),
                onTap: () {
                  controller.setEnglish();
                  Navigator.of(sheetContext).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  locale.languageCode == 'ar'
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: locale.languageCode == 'ar' ? MxColors.brand : null,
                  size: 20,
                ),
                title: Text(l10n.arabic),
                onTap: () {
                  controller.setArabic();
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSpeedSheet(
    BuildContext context,
    PlaybackPreferences prefs,
    PlaybackPreferencesController controller,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxSheetHeader(title: l10n.playbackSpeed),
              for (final double speed in AppConstants.playbackSpeeds)
                ListTile(
                  leading: Icon(
                    speed == prefs.defaultSpeed
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: speed == prefs.defaultSpeed ? MxColors.brand : null,
                    size: 20,
                  ),
                  title: Text(speed == 1 ? '1x • ${l10n.speedNormal}' : '${speed}x'),
                  onTap: () {
                    controller.setDefaultSpeed(speed);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showGestureDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.shortcuts),
        content: Text(l10n.gestureHint),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.snapshot});

  final LibrarySnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final int totalSize = snapshot?.videos.fold<int>(0, (int sum, item) => sum + item.fileSizeBytes) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            MxColors.brand.withOpacity(0.16),
            Theme.of(context).colorScheme.surface,
          ],
        ),
        border: Border.all(color: MxColors.brand.withOpacity(0.24)),
      ),
      child: Row(
        children: <Widget>[
          const MxLogo(size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 3),
                Text(
                  '${snapshot?.totalVideos ?? 0} ${l10n.videosCount} • ${Formatters.fileSize(totalSize)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.version} ${AppConstants.version}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
