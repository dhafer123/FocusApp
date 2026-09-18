import 'package:flutter/material.dart';

class IdleAnimation extends StatefulWidget {
  const IdleAnimation({
    super.key,
    this.size = 128,
    this.duration = const Duration(milliseconds: 1000),
  });

  final double size;
  final Duration duration;

  @override
  State<IdleAnimation> createState() => _IdleAnimationState();
}

class _IdleAnimationState extends State<IdleAnimation>
    with SingleTickerProviderStateMixin {
  static const int frameCount = 10;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

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
        final frame =
            (_controller.value * frameCount).floor() % frameCount;
        return ClipRect(
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: widget.size * frameCount,
              maxWidth: widget.size * frameCount,
              minHeight: widget.size,
              maxHeight: widget.size,
              child: Transform.translate(
                offset: Offset(-frame * widget.size, 0),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Image.asset(
        'assets/Idle.png',
        width: widget.size * frameCount,
        height: widget.size,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}