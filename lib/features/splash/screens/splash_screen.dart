import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/mx_common.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../home/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0.25, 1, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 1, curve: Curves.easeOutCubic)),
    );
    _controller.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 1500), _goHome);
  }

  void _goHome() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF08090B),
      body: Stack(
        children: <Widget>[
          // Ambient brand glow behind the mark.
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            child: IgnorePointer(
              child: Container(
                height: 480,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: <Color>[Color(0x333DDC84), Color(0x00000000)],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ScaleTransition(
                    scale: _logoScale,
                    child: const MxLogo(size: 104),
                  ),
                  const SizedBox(height: 26),
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              const Text(
                                'MX',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  height: 1,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'PLAYER',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 5,
                                    height: 1,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: MxColors.brand.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: MxColors.brand.withOpacity(0.4)),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w800,
                                color: MxColors.brand,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            l10n.splashTagline,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.white54, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 42,
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Color(0x1FFFFFFF),
                        valueColor: AlwaysStoppedAnimation<Color>(MxColors.brand),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppConstants.appName} • v${AppConstants.version}',
                    style: const TextStyle(fontSize: 10.5, color: Colors.white38, letterSpacing: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
