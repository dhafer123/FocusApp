import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.onReset,
    required this.onToggle,
    required this.onSkip,
  });

  final bool isRunning;
  final VoidCallback onReset;
  final VoidCallback onToggle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onReset,
          icon: const Icon(Icons.restart_alt_rounded),
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 78,
          height: 78,
          child: FilledButton(
            onPressed: onToggle,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.focusAccent,
              foregroundColor: Colors.black,
              shape: const CircleBorder(),
            ),
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 34,
            ),
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          onPressed: onSkip,
          icon: const Icon(Icons.skip_next_rounded),
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }
}
