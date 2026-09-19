import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/session_type.dart';

class SessionLabel extends StatelessWidget {
  const SessionLabel({super.key, required this.type});

  final SessionType type;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final color = switch (type) {
      SessionType.focus => colors.focusAccent,
      SessionType.shortBreak => colors.shortBreakAccent,
      SessionType.longBreak => colors.longBreakAccent,
    };

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 250),
      style: AppTheme.pixelText(size: 16, color: color, weight: FontWeight.w600),
      child: Text(_labelText(type)),
    );
  }

  String _labelText(SessionType type) {
    return switch (type) {
      SessionType.focus => 'Focus',
      SessionType.shortBreak => 'Short Break',
      SessionType.longBreak => 'Long Break',
    };
  }
}
