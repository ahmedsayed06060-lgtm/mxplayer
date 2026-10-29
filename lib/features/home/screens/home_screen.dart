import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../data/models/library_snapshot.dart';
import '../../../data/models/video_item.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../downloads/screens/download_manager_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../iptv/screens/iptv_screen.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/controllers/library_view_controller.dart';
import '../../library/folder_list/screens/folder_list_screen.dart';
import '../../library/models/library_view_state.dart';
import '../../library/video_list/screens/video_list_screen.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/models/playback_item.dart';
import '../../player/screens/player_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/mini_player_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;
  bool _searchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (_index == index) {
      return;
    }
    if (_searchOpen) {
      _closeSearch();
    }
    setState(() => _index = index);
  }

  void _openSearch() {
    setState(() => _searchOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  void _closeSearch() {
    _searchController.clear();
    ref.read(libraryViewControllerProvider.notifier).clearSearch();
    setState(() => _searchOpen = false);
  }

  Future<void> _openLocalFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.videoExtensions,
    );
    final String? path = result?.files.single.path;
    if (path == null) {
      return;
    }
    final LibrarySnapshot? snapshot = ref.read(libraryControllerProvider).valueOrNull;
    VideoItem? match;
    if (snapshot != null) {
      for (final VideoItem video in snapshot.videos) {
        if (video.path == path) {
          match = video;
          break;
        }
      }
    }

    final SharedPlayerController controller = ref.read(sharedPlayerControllerProvider.notifier);
    final VideoItem? known = match;
    if (known != null) {
      await controller.openVideoItem(known);
    } else {
      await controller.openNetwork(
        id: path,
        title: result?.files.single.name ?? path.split(RegExp(r'[/\\]')).last,
        url: Uri.file(path).toString(),
        type: PlaybackSourceType.local,
      );
    }
    if (mounted) {
      await Navigator.of(context).pushNamed(PlayerScreen.routeName);
    }
  }

  Future<void> _openStream() async {
    final TextEditingController controller = TextEditingController();
    final String? url = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        final AppLocalizations l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.openStream),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(labelText: l10n.streamUrl, hintText: l10n.streamHint),
            onSubmitted: (String value) => Navigator.of(dialogContext).pop(value),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: Text(l10n.play),
            ),
          ],
        );
      },
    );
    controller.dispose();
    final String target = (url ?? '').trim();
    if (target.isEmpty || !mounted) {
      return;
    }
    final Uri? uri = Uri.tryParse(target);
    final String title = (uri == null || uri.pathSegments.isEmpty)
        ? target
        : uri.pathSegments.last;
    await ref.read(sharedPlayerControllerProvider.notifier).openNetwork(
          id: target,
          title: title.isEmpty ? target : title,
          url: target,
          type: PlaybackSourceType.network,
        );
    if (mounted) {
      await Navigator.of(context).pushNamed(PlayerScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool wide = MediaQuery.sizeOf(context).width >= 900;
    final List<String> titles = <String>[
      l10n.videos,
      l10n.folders,
      l10n.iptv,
      l10n.favorites,
      l10n.settings,
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (wide)
              _SideRail(
                index: _index,
                titles: titles,
                onSelect: _selectTab,
                onDownloads: () => Navigator.of(context).pushNamed(DownloadManagerScreen.routeName),
              ),
            Expanded(
              child: Column(
                children: <Widget>[
                  _TopBar(
                    title: titles[_index],
                    index: _index,
                    searchOpen: _searchOpen,
                    searchController: _searchController,
                    searchFocus: _searchFocus,
                    onSearchToggle: () {
                      if (_searchOpen) {
                        _closeSearch();
                      } else {
                        _openSearch();
                      }
                    },
                    onPickFolder: () =>
                        ref.read(libraryControllerProvider.notifier).pickAndScanDirectory(),
                    onRefresh: () => ref.read(libraryControllerProvider.notifier).refresh(),
                    onOpenFile: _openLocalFile,
                    onOpenStream: _openStream,
                    onOpenDownloads: () =>
                        Navigator.of(context).pushNamed(DownloadManagerScreen.routeName),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOut,
                      child: KeyedSubtree(
                        key: ValueKey<int>(_index),
                        child: _buildBody(l10n),
                      ),
                    ),
                  ),
                  const MiniPlayerBar(),
                  if (!wide)
                    _BottomBar(
                      index: _index,
                      titles: titles,
                      onSelect: _selectTab,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final AsyncValue<LibrarySnapshot?> libraryState = ref.watch(libraryControllerProvider);

    if (_index == 2) {
      return const IptvScreen();
    }
    if (_index == 3) {
      return const FavoritesScreen();
    }
    if (_index == 4) {
      return const SettingsScreen();
    }

    return libraryState.when(
      loading: () => const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      error: (Object error, StackTrace stack) => MxEmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.scanFailed,
        message: error.toString(),
        actionLabel: l10n.retry,
        onAction: () => ref.read(libraryControllerProvider.notifier).refresh(),
      ),
      data: (LibrarySnapshot? snapshot) {
        if (_index == 1) {
          return FolderListScreen(
            folders: snapshot?.folders ?? const [],
          );
        }
        return VideoListScreen(
          videos: snapshot?.videos ?? const [],
        );
      },
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({
    required this.title,
    required this.index,
    required this.searchOpen,
    required this.searchController,
    required this.searchFocus,
    required this.onSearchToggle,
    required this.onPickFolder,
    required this.onRefresh,
    required this.onOpenFile,
    required this.onOpenStream,
    required this.onOpenDownloads,
  });

  final String title;
  final int index;
  final bool searchOpen;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final VoidCallback onSearchToggle;
  final VoidCallback onPickFolder;
  final VoidCallback onRefresh;
  final VoidCallback onOpenFile;
  final VoidCallback onOpenStream;
  final VoidCallback onOpenDownloads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool searchable = index <= 1;
    final bool showWordmark = MediaQuery.sizeOf(context).width >= 430;
    final LibraryViewState viewState = ref.watch(libraryViewControllerProvider);

    if (searchOpen && searchable) {
      return Container(
        padding: const EdgeInsets.fromLTRB(6, 8, 10, 8),
        color: isDark ? MxColors.background : MxColors.lightBackground,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onSearchToggle,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                focusNode: searchFocus,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: viewState.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();
                            ref.read(libraryViewControllerProvider.notifier).clearSearch();
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (String value) =>
                    ref.read(libraryViewControllerProvider.notifier).setSearchQuery(value),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 58,
      padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
      color: isDark ? MxColors.background : MxColors.lightBackground,
      child: Row(
        children: <Widget>[
          if (showWordmark) ...<Widget>[
            const MxWordmark(logoSize: 28, subtitle: 'PRO', compact: true),
            const SizedBox(width: 12),
            Container(width: 1, height: 18, color: isDark ? MxColors.divider : MxColors.lightDivider),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
          ),
          if (searchable)
            IconButton(
              tooltip: l10n.search,
              onPressed: onSearchToggle,
              icon: const Icon(Icons.search_rounded, size: 22),
            ),
          IconButton(
            tooltip: l10n.openDownloads,
            onPressed: onOpenDownloads,
            icon: const Icon(Icons.file_download_outlined, size: 22),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.more,
            icon: const Icon(Icons.more_vert_rounded, size: 22),
            onSelected: (String value) {
              switch (value) {
                case 'folder':
                  onPickFolder();
                  break;
                case 'refresh':
                  onRefresh();
                  break;
                case 'file':
                  onOpenFile();
                  break;
                case 'stream':
                  onOpenStream();
                  break;
                case 'downloads':
                  onOpenDownloads();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'folder',
                child: _menuRow(Icons.create_new_folder_outlined, l10n.selectFolder),
              ),
              PopupMenuItem<String>(
                value: 'refresh',
                child: _menuRow(Icons.refresh_rounded, l10n.scanAgain),
              ),
              PopupMenuItem<String>(
                value: 'file',
                child: _menuRow(Icons.play_circle_outline_rounded, l10n.pickLocalMedia),
              ),
              PopupMenuItem<String>(
                value: 'stream',
                child: _menuRow(Icons.podcasts_rounded, l10n.openStream),
              ),
              PopupMenuItem<String>(
                value: 'downloads',
                child: _menuRow(Icons.download_rounded, l10n.openDownloads),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuRow(IconData icon, String label) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.titles, required this.onSelect});

  final int index;
  final List<String> titles;
  final ValueChanged<int> onSelect;

  static const List<IconData> _icons = <IconData>[
    Icons.video_library_outlined,
    Icons.folder_outlined,
    Icons.live_tv_outlined,
    Icons.favorite_border_rounded,
    Icons.settings_outlined,
  ];

  static const List<IconData> _activeIcons = <IconData>[
    Icons.video_library_rounded,
    Icons.folder_rounded,
    Icons.live_tv_rounded,
    Icons.favorite_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101215) : MxColors.lightSurface,
        border: Border(
          top: BorderSide(color: isDark ? MxColors.divider : MxColors.lightDivider, width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < titles.length; i++)
                Expanded(
                  child: InkResponse(
                    onTap: () => onSelect(i),
                    radius: 34,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          index == i ? _activeIcons[i] : _icons[i],
                          size: 22,
                          color: index == i ? MxColors.brand : MxColors.textTertiary,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          titles[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.8,
                            fontWeight: index == i ? FontWeight.w700 : FontWeight.w500,
                            color: index == i ? MxColors.brand : MxColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.index,
    required this.titles,
    required this.onSelect,
    required this.onDownloads,
  });

  final int index;
  final List<String> titles;
  final ValueChanged<int> onSelect;
  final VoidCallback onDownloads;

  static const List<IconData> _icons = <IconData>[
    Icons.video_library_outlined,
    Icons.folder_outlined,
    Icons.live_tv_outlined,
    Icons.favorite_border_rounded,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101215) : MxColors.lightSurface,
        border: Border(
          right: BorderSide(color: isDark ? MxColors.divider : MxColors.lightDivider, width: 0.8),
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 18),
          const MxLogo(size: 38, showShadow: false),
          const SizedBox(height: 22),
          for (int i = 0; i < titles.length; i++)
            _RailItem(
              icon: _icons[i],
              label: titles[i],
              selected: index == i,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          _RailItem(
            icon: Icons.download_rounded,
            label: 'DL',
            selected: false,
            onTap: onDownloads,
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: selected ? MxColors.brand.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 22,
                color: selected ? MxColors.brand : MxColors.textTertiary,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? MxColors.brand : MxColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
