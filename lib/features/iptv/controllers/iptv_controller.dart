import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/iptv_channel.dart';
import '../../../services/iptv_service.dart';

final iptvControllerProvider =
    AsyncNotifierProvider<IptvController, IptvState>(IptvController.new);

class IptvState {
  const IptvState({
    this.playlistUrl = '',
    this.channels = const [],
    this.search = '',
  });

  final String playlistUrl;
  final List<IptvChannel> channels;
  final String search;

  List<IptvChannel> get filteredChannels {
    if (search.trim().isEmpty) {
      return channels;
    }
    final query = search.toLowerCase();
    return channels.where((channel) => channel.name.toLowerCase().contains(query)).toList();
  }

  IptvState copyWith({
    String? playlistUrl,
    List<IptvChannel>? channels,
    String? search,
  }) {
    return IptvState(
      playlistUrl: playlistUrl ?? this.playlistUrl,
      channels: channels ?? this.channels,
      search: search ?? this.search,
    );
  }
}

class IptvController extends AsyncNotifier<IptvState> {
  late final IptvService _service;

  @override
  Future<IptvState> build() async {
    _service = IptvService();
    return const IptvState();
  }

  Future<void> loadPlaylist(String url) async {
    final current = state.valueOrNull ?? const IptvState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final channels = await _service.loadPlaylist(url);
      return current.copyWith(playlistUrl: url, channels: channels);
    });
  }

  void setSearch(String value) {
    final current = state.valueOrNull ?? const IptvState();
    state = AsyncData(current.copyWith(search: value));
  }
}
