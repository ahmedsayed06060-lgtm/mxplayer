import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../downloads/screens/download_manager_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../iptv/screens/iptv_screen.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/folder_list/screens/folder_list_screen.dart';
import '../../library/video_list/screens/video_list_screen.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/screens/player_screen.dart';
import '../../settings/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final libraryState = ref.watch(libraryControllerProvider);
    final playerState = ref.watch(sharedPlayerControllerProvider);

    final titles = [
      l10n.videos,
      l10n.folders,
      l10n.iptv,
      l10n.favorites,
      l10n.settings,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          if (_index <= 1)
            IconButton(
              tooltip: l10n.selectFolder,
              onPressed: () {
                ref.read(libraryControllerProvider.notifier).pickAndScanDirectory();
              },
              icon: const Icon(Icons.create_new_folder_outlined),
            ),
          if (_index <= 1)
            IconButton(
              tooltip: l10n.refresh,
              onPressed: () {
                ref.read(libraryControllerProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          IconButton(
            tooltip: l10n.pickLocalMedia,
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp4', 'mkv', 'avi', 'mov', 'flv', 'wmv', 'webm', 'm4v'],
              );
              final path = result?.files.single.path;
              if (path == null) {
                return;
              }
              final matches = libraryState.valueOrNull?.videos.where((item) => item.path == path).toList() ?? const [];
              if (matches.isNotEmpty) {
                await ref.read(sharedPlayerControllerProvider.notifier).openVideoItem(matches.first);
              } else {
                await ref.read(sharedPlayerControllerProvider.notifier).openNetwork(
                      id: path,
                      title: result?.files.single.name ?? path,
                      url: Uri.file(path).toString(),
                      type: PlaybackSourceType.local,
                    );
              }
              if (context.mounted) {
                Navigator.of(context).pushNamed(PlayerScreen.routeName);
              }
            },
            icon: const Icon(Icons.video_file_outlined),
          ),
          IconButton(
            tooltip: l10n.openDownloads,
            onPressed: () => Navigator.of(context).pushNamed(DownloadManagerScreen.routeName),
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: libraryState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${l10n.scanFailed}: $error')),
        data: (snapshot) {
          final views = [
            VideoListScreen(videos: snapshot?.videos ?? const []),
            FolderListScreen(folders: snapshot?.folders ?? const []),
            const IptvScreen(),
            const FavoritesScreen(),
            const SettingsScreen(),
          ];
          return IndexedStack(index: _index, children: views);
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playerState.hasMedia) const _MiniPlayerBar(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: [
              NavigationDestination(icon: const Icon(Icons.video_library_outlined), label: l10n.videos),
              NavigationDestination(icon: const Icon(Icons.folder_open_outlined), label: l10n.folders),
              NavigationDestination(icon: const Icon(Icons.live_tv_outlined), label: l10n.iptv),
              NavigationDestination(icon: const Icon(Icons.favorite_border), label: l10n.favorites),
              NavigationDestination(icon: const Icon(Icons.settings_outlined), label: l10n.settings),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPlayerBar extends ConsumerWidget {
  const _MiniPlayerBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sharedPlayerControllerProvider);
    final controller = ref.read(sharedPlayerControllerProvider.notifier);
    if (!state.hasMedia) {
      return const SizedBox.shrink();
    }

    return Material(
      color: const Color(0xFF171A21),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(PlayerScreen.routeName),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2A37), Color(0xFF111827)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.play_circle_fill_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.current!.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.duration(state.position)} / ${Formatters.duration(state.duration)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: controller.togglePlayPause,
                icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
              ),
              IconButton(
                onPressed: controller.stop,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
