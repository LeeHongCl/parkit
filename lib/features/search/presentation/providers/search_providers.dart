import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../data/recent_search_repository.dart';
import '../../domain/destination.dart';

class SelectedDestinationNotifier extends Notifier<Destination?> {
  @override
  Destination? build() => null;

  void select(Destination destination) => state = destination;
}

final selectedDestinationProvider =
    NotifierProvider<SelectedDestinationNotifier, Destination?>(
  SelectedDestinationNotifier.new,
);

final recentSearchRepositoryProvider = Provider<RecentSearchRepository>((ref) {
  return RecentSearchRepository(ref.watch(sharedPreferencesProvider));
});

class RecentSearchesNotifier extends Notifier<List<Destination>> {
  @override
  List<Destination> build() => ref.watch(recentSearchRepositoryProvider).getRecentSearches();

  Future<void> add(Destination destination) async {
    await ref.read(recentSearchRepositoryProvider).addRecentSearch(destination);
    state = ref.read(recentSearchRepositoryProvider).getRecentSearches();
  }

  Future<void> clear() async {
    await ref.read(recentSearchRepositoryProvider).clearRecentSearches();
    state = const [];
  }
}

final recentSearchesProvider = NotifierProvider<RecentSearchesNotifier, List<Destination>>(
  RecentSearchesNotifier.new,
);
