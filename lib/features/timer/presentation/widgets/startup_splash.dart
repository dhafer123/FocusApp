import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../core/theme/app_theme.dart';

class StartupSplash extends StatefulWidget {
  const StartupSplash({super.key, required this.child});

  final Widget child;

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash>
    {
  Timer? _dismissTimer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) return widget.child;

    final colors = AppTheme.colors(context);
    return Material(
      color: colors.background,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BoxCatAnimation(color: colors.textPrimary),
              const SizedBox(height: 28),
              Text(
                'WHISKER WORK',
                style: AppTheme.pixelText(
                  size: 20,
                  color: colors.textPrimary,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              LoadingAnimationWidget.staggeredDotsWave(
                color: colors.focusAccent,
                size: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoxCatAnimation extends StatefulWidget {
  const _BoxCatAnimation({required this.color});

  final Color color;

  @override
  State<_BoxCatAnimation> createState() => _BoxCatAnimationState();
}

class _BoxCatAnimationState extends State<_BoxCatAnimation>
    with SingleTickerProviderStateMixin {

  static const frameCount = 4;
  static const frameSize = 128.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final frame = (_controller.value * frameCount).floor() % frameCount;
        return ClipRect(
          child: SizedBox(
            width: frameSize,
            height: frameSize,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: frameSize * frameCount,
              maxWidth: frameSize * frameCount,
              minHeight: frameSize,
              maxHeight: frameSize,
              child: Transform.translate(
                offset: Offset(-frame * frameSize, 0),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Image.asset(
        'assets/Box3.png',
        width: frameSize * frameCount,
        height: frameSize,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}