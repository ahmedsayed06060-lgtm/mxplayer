import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../data/models/iptv_channel.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/models/playback_item.dart';
import '../../player/screens/player_screen.dart';
import '../controllers/iptv_controller.dart';

class IptvScreen extends ConsumerStatefulWidget {
  const IptvScreen({super.key});

  @override
  ConsumerState<IptvScreen> createState() => _IptvScreenState();
}

class _IptvScreenState extends ConsumerState<IptvScreen> {
  final TextEditingController _playlistController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _group;

  @override
  void dispose() {
    _playlistController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final String url = _playlistController.text.trim();
    if (url.isEmpty) {
      return;
    }
    await ref.read(iptvControllerProvider.notifier).loadPlaylist(url);
    if (!mounted) {
      return;
    }
    final AsyncValue<IptvState> state = ref.read(iptvControllerProvider);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final IptvState? data = state.valueOrNull;
    final String message = state.hasError
        ? '${l10n.invalidPlaylist}: ${state.error}'
        : '${l10n.playlistLoaded} • ${data?.channels.length ?? 0} ${l10n.channels}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<IptvState> asyncState = ref.watch(iptvControllerProvider);
    final Set<String> favorites = ref.watch(favoritesControllerProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return asyncState.when(
      loading: () => const Center(
        child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5)),
      ),
      error: (Object error, StackTrace stack) => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _PlaylistCard(
            controller: _playlistController,
            onLoad: _load,
          ),
          const SizedBox(height: 40),
          MxEmptyState(
            icon: Icons.error_outline_rounded,
            title: l10n.invalidPlaylist,
            message: error.toString(),
            actionLabel: l10n.retry,
            onAction: _load,
          ),
        ],
      ),
      data: (IptvState state) {
        final List<String> groups = <String>{
          for (final IptvChannel channel in state.channels)
            if ((channel.groupTitle ?? '').trim().isNotEmpty) channel.groupTitle!.trim(),
        }.toList();

        final List<IptvChannel> visible = state.filteredChannels
            .where((IptvChannel channel) =>
                _group == null || (channel.groupTitle ?? '').trim() == _group)
            .toList();

        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _PlaylistCard(controller: _playlistController, onLoad: _load),
                    if (state.channels.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.channelSearch,
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          isDense: true,
                        ),
                        onChanged: ref.read(iptvControllerProvider.notifier).setSearch,
                      ),
                      if (groups.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(l10n.all),
                                  selected: _group == null,
                                  onSelected: (_) => setState(() => _group = null),
                                ),
                              ),
                              for (final String group in groups)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(group),
                                    selected: _group == group,
                                    onSelected: (_) => setState(() => _group = group),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      MxSectionHeader(
                        title: l10n.channels,
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                        trailing: Text(
                          '${visible.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MxColors.brand),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (visible.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: MxEmptyState(
                    compact: true,
                    icon: Icons.live_tv_outlined,
                    title: l10n.noChannels,
                    message: l10n.iptvHint,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 140),
                sliver: SliverList.builder(
                  itemCount: visible.length,
                  itemBuilder: (BuildContext context, int index) {
                    final IptvChannel channel = visible[index];
                    final bool isFavorite = favorites.contains(channel.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MxSurface(
                        radius: 14,
                        border: false,
                        onTap: () async {
                          await ref.read(sharedPlayerControllerProvider.notifier).openNetwork(
                                id: channel.id,
                                title: channel.name,
                                url: channel.url,
                                type: PlaybackSourceType.iptv,
                              );
                          if (context.mounted) {
                            await Navigator.of(context).pushNamed(PlayerScreen.routeName);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                          child: Row(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 56,
                                  height: 40,
                                  color: isDark ? MxColors.surfaceHigh : MxColors.lightSurfaceAlt,
                                  child: channel.logo == null
                                      ? const Icon(Icons.live_tv_rounded, size: 20, color: MxColors.brand)
                                      : Image.network(
                                          channel.logo!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.live_tv_rounded,
                                            size: 20,
                                            color: MxColors.brand,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      channel.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      channel.groupTitle ?? l10n.iptv,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => ref
                                    .read(favoritesControllerProvider.notifier)
                                    .toggle(channel.id),
                                icon: Icon(
                                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 19,
                                  color: isFavorite ? MxColors.brand : null,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.play_circle_outline_rounded, size: 22),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.controller, required this.onLoad});

  final TextEditingController controller;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return MxSurface(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: MxColors.brand.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.podcasts_rounded, size: 18, color: MxColors.brand),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(l10n.iptv, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                    Text(l10n.iptvHint, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: l10n.playlistUrl,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => onLoad(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onLoad,
                style: FilledButton.styleFrom(
                  backgroundColor: MxColors.brand,
                  foregroundColor: const Color(0xFF06210F),
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.loadPlaylist, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
