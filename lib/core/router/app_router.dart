import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../../features/timer/presentation/pages/timer_page.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (context, state) => const TimerPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
            ],
          ),
        ],
      ),
    ],
  );
}
