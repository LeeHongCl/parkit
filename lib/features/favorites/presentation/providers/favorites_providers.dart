import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../parking/domain/parking_lot.dart';
import '../../../parking/presentation/providers/parking_providers.dart';
import '../../data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(sharedPreferencesProvider));
});

class FavoriteIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(favoritesRepositoryProvider).getFavoriteIds();

  Future<void> toggle(String parkingLotId) async {
    final updated = {...state};
    if (updated.contains(parkingLotId)) {
      updated.remove(parkingLotId);
    } else {
      updated.add(parkingLotId);
    }
    state = updated;
    await ref.read(favoritesRepositoryProvider).setFavoriteIds(updated);
  }
}

final favoriteIdsProvider = NotifierProvider<FavoriteIdsNotifier, Set<String>>(
  FavoriteIdsNotifier.new,
);

final favoriteParkingLotsProvider = FutureProvider.autoDispose<List<ParkingLot>>((ref) async {
  final ids = ref.watch(favoriteIdsProvider);
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.getParkingLotsByIds(ids.toList());
});
