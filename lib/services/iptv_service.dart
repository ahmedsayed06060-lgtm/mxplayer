import 'dart:io';

import '../data/models/iptv_channel.dart';

class IptvService {
  Future<List<IptvChannel>> loadPlaylist(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final body = await response.transform(SystemEncoding().decoder).join();
      return _parseM3u(body);
    } finally {
      client.close(force: true);
    }
  }

  List<IptvChannel> _parseM3u(String body) {
    final lines = body.split(RegExp(r'\r?\n'));
    final channels = <IptvChannel>[];
    String? pendingName;
    String? pendingLogo;
    String? pendingGroup;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }
      if (line.startsWith('#EXTINF')) {
        final commaIndex = line.indexOf(',');
        pendingName = commaIndex == -1 ? 'Channel' : line.substring(commaIndex + 1).trim();
        pendingLogo = _attribute(line, 'tvg-logo');
        pendingGroup = _attribute(line, 'group-title');
        continue;
      }
      if (!line.startsWith('#')) {
        channels.add(
          IptvChannel(
            id: '$line|${pendingName ?? line}',
            name: pendingName ?? line,
            url: line,
            logo: pendingLogo,
            groupTitle: pendingGroup,
          ),
        );
        pendingName = null;
        pendingLogo = null;
        pendingGroup = null;
      }
    }

    return channels;
  }

  String? _attribute(String line, String key) {
    final regex = RegExp('$key="([^"]+)"');
    return regex.firstMatch(line)?.group(1);
  }
}
