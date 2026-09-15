import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SessionDots extends StatelessWidget {
  const SessionDots({super.key, required this.completed});

  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final active = index < completed % 4;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppTheme.focusAccent : Colors.white.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}
