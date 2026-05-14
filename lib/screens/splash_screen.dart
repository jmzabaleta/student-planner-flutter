import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../providers/planner_provider.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glowOpacity;
  bool _hasBooted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.94, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _logoOpacity = Tween<double>(
      begin: 0.88,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowOpacity = Tween<double>(
      begin: 0.18,
      end: 0.42,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasBooted) return;

    _hasBooted = true;
    _prepareApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _prepareApp() async {
    final planner = context.read<PlannerProvider>();
    final settings = context.read<SettingsProvider>();
    const minimumSplashTime = Duration(milliseconds: 1100);
    const startupTimeout = Duration(milliseconds: 2400);

    try {
      await Future.wait([
        planner.loadData().timeout(startupTimeout),
        settings.loadSettings().timeout(startupTimeout),
        Future<void>.delayed(minimumSplashTime),
      ]).timeout(const Duration(milliseconds: 2800));

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 520),
          pageBuilder: (_, animation, _) {
            return FadeTransition(
              opacity: animation,
              child: const HomeScreen(),
            );
          },
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 420),
          pageBuilder: (_, animation, _) {
            return FadeTransition(
              opacity: animation,
              child: const HomeScreen(),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7FBFF), Color(0xFFDFF2FF), Color(0xFFFFD17D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final rotation =
                      math.sin(_controller.value * math.pi * 2) * 0.018;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: _glowOpacity.value,
                            child: Container(
                              width: 210,
                              height: 210,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFF28A00),
                                    blurRadius: 56,
                                    spreadRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: rotation,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Opacity(
                                opacity: _logoOpacity.value,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(46),
                                  child: Image.asset(
                                    'assets/images/gaara_icon.png',
                                    width: 156,
                                    height: 156,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Gaara',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: const Color(0xFF10233F),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preparando tu espacio',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF35516F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 128,
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: Colors.white.withValues(
                            alpha: 0.48,
                          ),
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
