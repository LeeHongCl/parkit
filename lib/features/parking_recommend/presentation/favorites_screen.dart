import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/favorite_parking_lot.dart';
import '../data/parking_api_client.dart';
import 'providers/favorites_providers.dart';
import 'providers/parking_recommend_providers.dart';

/// 즐겨찾기에는 id/이름/주소/좌표만 저장한다(명세상 lot 단건 조회 API가 없어서,
/// 상세를 다시 볼 때는 그 좌표를 중심으로 recommend를 다시 호출해 최신 정보를 가져온다).
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int? _loadingId;

  Future<void> _openDetail(FavoriteParkingLot favorite) async {
    setState(() => _loadingId = favorite.id);
    final client = ref.read(parkingApiClientProvider);
    try {
      final result = await client.fetchRecommend(
        lat: favorite.location.lat,
        lng: favorite.location.lng,
        radius: 100,
        limit: 5,
        includeUnknown: true,
        destinationIsBuilding: true,
        excludeClosed: false,
      );
      final match = result.items.where((item) => item.id == favorite.id).firstOrNull;
      if (!mounted) return;
      setState(() => _loadingId = null);

      if (match == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('최신 정보를 불러오지 못했습니다.')),
        );
        return;
      }

      final dataUpdatedDate = ref.read(metaResultProvider).value?.displayDate;
      if (!mounted) return;
      context.push('/detail', extra: {
        'item': match,
        'durationMinutes': ref.read(durationMinutesProvider),
        'dataUpdatedDate': dataUpdatedDate,
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingId = null);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: favorites.isEmpty
          ? const Center(child: Text('즐겨찾기한 주차장이 없습니다.'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return ListTile(
                  leading: const Icon(Icons.local_parking),
                  title: Text(favorite.name),
                  subtitle: favorite.address != null ? Text(favorite.address!) : null,
                  trailing: _loadingId == favorite.id
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.favorite),
                          color: Theme.of(context).colorScheme.error,
                          onPressed: () => ref.read(favoritesProvider.notifier).remove(favorite.id),
                          tooltip: '즐겨찾기 해제',
                        ),
                  onTap: _loadingId != null ? null : () => _openDetail(favorite),
                );
              },
            ),
    );
  }
}
