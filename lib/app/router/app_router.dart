import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/parking_recommend/data/models/recommend_item.dart';
import '../../features/parking_recommend/presentation/detail_screen.dart';
import '../../features/parking_recommend/presentation/main_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
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
