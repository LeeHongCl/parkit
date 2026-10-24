import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/parking_recommend/data/models/recommend_item.dart';
import '../../features/parking_recommend/presentation/detail_screen.dart';
import '../../features/parking_recommend/presentation/favorites_screen.dart';
import '../../features/parking_recommend/presentation/main_screen.dart';
import '../../features/parking_recommend/presentation/search_screen.dart';
import '../../features/parking_recommend/presentation/settings_screen.dart';
import '../widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
          GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
          GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return DetailScreen(
            item: extra['item'] as RecommendItem,
            durationMinutes: extra['durationMinutes'] as int,
            dataUpdatedDate: extra['dataUpdatedDate'] as String?,
          );
        },
      ),
    ],
  );
});
