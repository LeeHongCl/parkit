import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../data/favorites_repository.dart';
import '../../data/models/favorite_parking_lot.dart';
import '../../data/models/recommend_item.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(sharedPreferencesProvider));
});

class FavoritesNotifier extends Notifier<List<FavoriteParkingLot>> {
  @override
  List<FavoriteParkingLot> build() => ref.watch(favoritesRepositoryProvider).getFavorites();

  bool isFavorite(int id) => state.any((f) => f.id == id);

  Future<void> toggle(RecommendItem item) async {
    final isFav = isFavorite(item.id);
    final updated = isFav
        ? state.where((f) => f.id != item.id).toList()
        : [...state, FavoriteParkingLot.fromRecommendItem(item)];
    state = updated;
    await ref.read(favoritesRepositoryProvider).saveFavorites(updated);
  }

  Future<void> remove(int id) async {
    final updated = state.where((f) => f.id != id).toList();
    state = updated;
    await ref.read(favoritesRepositoryProvider).saveFavorites(updated);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<FavoriteParkingLot>>(
  FavoritesNotifier.new,
);
