import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/session_type.dart';

class SessionLabel extends StatelessWidget {
  const SessionLabel({super.key, required this.type});

  final SessionType type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      SessionType.focus => AppTheme.focusAccent,
      SessionType.shortBreak => AppTheme.shortBreakAccent,
      SessionType.longBreak => AppTheme.longBreakAccent,
    };

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 250),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
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
