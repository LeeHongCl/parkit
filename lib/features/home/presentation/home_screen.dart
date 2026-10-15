import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/mock_map_placeholder.dart';
import '../../favorites/presentation/providers/favorites_providers.dart';
import '../../parking/presentation/providers/parking_providers.dart';
import '../../parking/presentation/widgets/parking_list_item.dart';
import '../../search/domain/destination.dart';
import '../../search/presentation/providers/search_providers.dart';
import 'widgets/ai_prompt_entry_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = ref.watch(selectedDestinationProvider) ?? Destination.sample;
    final lotsAsync = ref.watch(nearbyParkingLotsProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('PARKIT')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(nearbyParkingLotsProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchEntryField(destination: destination),
                    const SizedBox(height: 16),
                    lotsAsync.maybeWhen(
                      data: (lots) => MockMapPlaceholder(parkingLots: lots),
                      orElse: () => const MockMapPlaceholder(parkingLots: []),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push('/recommendation'),
                      icon: const Icon(Icons.tune),
                      label: const Text('맞춤 주차장 추천 받기'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                    const SizedBox(height: 12),
                    AiPromptEntryCard(
                      onSubmit: (prompt) =>
                          context.push('/ai-recommendation', extra: prompt),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '"${destination.name}" 주변 주차장',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            lotsAsync.when(
              data: (lots) {
                if (lots.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('주변에 표시할 주차장이 없습니다.')),
                  );
                }
                return SliverList.builder(
                  itemCount: lots.length,
                  itemBuilder: (context, index) {
                    final lot = lots[index];
                    return ParkingListItem(
                      parkingLot: lot,
                      isFavorite: favoriteIds.contains(lot.id),
                      onTap: () => context.push('/parking/${lot.id}'),
                      onToggleFavorite: () =>
                          ref.read(favoriteIdsProvider.notifier).toggle(lot.id),
                    );
                  },
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('주차장 정보를 불러오지 못했습니다.\n$error')),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _SearchEntryField extends StatelessWidget {
  final Destination destination;
  const _SearchEntryField({required this.destination});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 12),
            Expanded(
              child: Text(destination.name, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
