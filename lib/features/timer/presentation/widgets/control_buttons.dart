import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.accent,
    required this.onReset,
    required this.onToggle,
    required this.onSkip,
  });

  final bool isRunning;
  final Color accent;
  final VoidCallback onReset;
  final VoidCallback onToggle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PixelButton(label: 'R', onPressed: onReset, accent: accent),
        const SizedBox(width: 24),
        SizedBox(
          width: 78,
          height: 78,
          child: FilledButton(
            onPressed: onToggle,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: colors.blockShadow,
              shape: const BeveledRectangleBorder(),
            ),
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 34,
            ),
          ),
        ),
        const SizedBox(width: 24),
        _PixelButton(label: '>', onPressed: onSkip, accent: accent),
      ],
    );
  }
}

class _PixelButton extends StatelessWidget {
  const _PixelButton({required this.label, required this.onPressed, required this.accent});

  final String label;
  final VoidCallback onPressed;
  final Color accent;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 56,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent, width: 2),
            shape: const BeveledRectangleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: Text(label, style: AppTheme.pixelText(size: 20, color: accent, weight: FontWeight.w700)),
        ),
      );
}
