import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/generated/app_localizations.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/screens/player_screen.dart';
import '../controllers/iptv_controller.dart';

class IptvScreen extends ConsumerStatefulWidget {
  const IptvScreen({super.key});

  @override
  ConsumerState<IptvScreen> createState() => _IptvScreenState();
}

class _IptvScreenState extends ConsumerState<IptvScreen> {
  late final TextEditingController _playlistController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _playlistController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _playlistController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(iptvControllerProvider);
    final favorites = ref.watch(favoritesControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('${l10n.invalidPlaylist}: $error')),
      data: (data) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            TextField(
              controller: _playlistController,
              decoration: InputDecoration(
                labelText: l10n.playlistUrl,
                hintText: l10n.iptvHint,
                suffixIcon: IconButton(
                  onPressed: () {
                    ref.read(iptvControllerProvider.notifier).loadPlaylist(_playlistController.text.trim());
                  },
                  icon: const Icon(Icons.cloud_download_outlined),
                ),
              ),
              onSubmitted: (value) {
                ref.read(iptvControllerProvider.notifier).loadPlaylist(value.trim());
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.channelSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: ref.read(iptvControllerProvider.notifier).setSearch,
            ),
            const SizedBox(height: 16),
            if (data.filteredChannels.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Center(child: Text(l10n.noChannels)),
              )
            else
              ...data.filteredChannels.map(
                (channel) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: channel.logo == null ? null : NetworkImage(channel.logo!),
                      child: channel.logo == null ? const Icon(Icons.live_tv_rounded) : null,
                    ),
                    title: Text(channel.name),
                    subtitle: Text(channel.groupTitle ?? l10n.iptv),
                    trailing: IconButton(
                      onPressed: () {
                        ref.read(favoritesControllerProvider.notifier).toggle(channel.id);
                      },
                      icon: Icon(favorites.contains(channel.id) ? Icons.favorite : Icons.favorite_border),
                    ),
                    onTap: () async {
                      await ref.read(sharedPlayerControllerProvider.notifier).openNetwork(
                            id: channel.id,
                            title: channel.name,
                            url: channel.url,
                            type: PlaybackSourceType.iptv,
                          );
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(PlayerScreen.routeName);
                      }
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
