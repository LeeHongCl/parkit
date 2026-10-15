import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../parking/presentation/widgets/parking_list_item.dart';
import 'providers/favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoriteIdsProvider);
    final favoriteLotsAsync = ref.watch(favoriteParkingLotsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: favoriteLotsAsync.when(
        data: (lots) {
          if (lots.isEmpty) {
            return const Center(child: Text('즐겨찾기한 주차장이 없습니다.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: lots.length,
            itemBuilder: (context, index) {
              final lot = lots[index];
              return ParkingListItem(
                parkingLot: lot,
                isFavorite: favoriteIds.contains(lot.id),
                onTap: () => context.push('/parking/${lot.id}'),
                onToggleFavorite: () => ref.read(favoriteIdsProvider.notifier).toggle(lot.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('즐겨찾기를 불러오지 못했습니다.\n$error')),
      ),
    );
  }
}
