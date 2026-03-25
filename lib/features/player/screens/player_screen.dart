import 'package:flutter/material.dart';
import '../../../localization/generated/app_localizations.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  static const String routeName = '/player';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.player)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.ondemand_video_outlined, size: 72),
              const SizedBox(height: 16),
              Text(
                l10n.playerPlaceholderTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.playerPlaceholderBody,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


