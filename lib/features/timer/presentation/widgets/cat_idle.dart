import 'package:flutter/material.dart';

class CatIdle extends StatefulWidget {
  const CatIdle({super.key});

  @override
  State<CatIdle> createState() => _CatIdleState();
}

class _CatIdleState extends State<CatIdle>
    with SingleTickerProviderStateMixin {
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
        final frame = (_controller.value * 10).floor();
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1 / 10,
            child: Transform.translate(
              offset: Offset(-frame * 32, 0),
              child: child,
            ),
          ),
        );
      },
      child: Image.asset(
        'assets/Idle.png',
        width: 320,
        height: 32,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}