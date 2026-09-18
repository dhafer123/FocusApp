import 'package:flutter/material.dart';

import 'idle_animation.dart';

class CampfireScene extends StatelessWidget {
  const CampfireScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/background.jpg',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.none,
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final glowSize = constraints.maxWidth * 0.23;
              return Stack(
                children: [
                  Positioned(
                    left: constraints.maxWidth * 0.61,
                    top: constraints.maxHeight * 0.61,
                    width: glowSize,
                    height: glowSize,
                    child: IdleAnimation(size: glowSize),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
