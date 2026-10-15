import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/format_utils.dart';
import '../../favorites/presentation/providers/favorites_providers.dart';
import '../../search/domain/destination.dart';
import '../../search/presentation/providers/search_providers.dart';
import '../../settings/presentation/providers/settings_providers.dart';
import '../domain/parking_recommendation.dart';
import '../domain/recommendation_type.dart';
import 'providers/recommendation_providers.dart';

class RecommendationScreen extends ConsumerStatefulWidget {
  const RecommendationScreen({super.key});

  @override
  ConsumerState<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final defaultType = ref.read(defaultRecommendationTypeProvider);
      ref.read(recommendationTypeProvider.notifier).select(defaultType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final destination = ref.watch(selectedDestinationProvider) ?? Destination.sample;
    final recommendationType = ref.watch(recommendationTypeProvider);
    final durationMinutes = ref.watch(parkingDurationMinutesProvider);
    final recommendationsAsync = ref.watch(recommendationsProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('주차장 추천')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('목적지: ${destination.name}', style: Theme.of(context).textTheme.titleMedium),
                Text(destination.address, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text('예상 주차 시간', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                _DurationSelector(
                  minutes: durationMinutes,
                  onChanged: (value) =>
                      ref.read(parkingDurationMinutesProvider.notifier).select(value),
                ),
                const SizedBox(height: 16),
                Text('추천 유형', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                _RecommendationTypeSelector(
                  selected: recommendationType,
                  onChanged: (value) =>
                      ref.read(recommendationTypeProvider.notifier).select(value),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: recommendationsAsync.when(
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return const Center(child: Text('추천할 주차장이 없습니다.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = recommendations[index];
                    return _RecommendationCard(
                      rank: index + 1,
                      recommendation: recommendation,
                      isFavorite: favoriteIds.contains(recommendation.parkingLot.id),
                      onTap: () => context.push('/parking/${recommendation.parkingLot.id}'),
                      onToggleFavorite: () => ref
                          .read(favoriteIdsProvider.notifier)
                          .toggle(recommendation.parkingLot.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('추천 결과를 불러오지 못했습니다.\n$error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;

  const _DurationSelector({required this.minutes, required this.onChanged});

  static const _options = [30, 60, 120, 180, 240, 360];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _options.map((value) {
        final hours = value ~/ 60;
        final remainder = value % 60;
        final label = value < 60 ? '$value분' : '$hours시간${remainder == 0 ? '' : ' $remainder분'}';
        return ChoiceChip(
          label: Text(label),
          selected: minutes == value,
          onSelected: (_) => onChanged(value),
        );
      }).toList(),
    );
  }
}

class _RecommendationTypeSelector extends StatelessWidget {
  final RecommendationType selected;
  final ValueChanged<RecommendationType> onChanged;

  const _RecommendationTypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RecommendationType>(
      segments: RecommendationType.values
          .map((type) => ButtonSegment(value: type, label: Text(type.label)))
          .toList(),
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final int rank;
  final ParkingRecommendation recommendation;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _RecommendationCard({
    required this.rank,
    required this.recommendation,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lot = recommendation.parkingLot;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 14, child: Text('$rank')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lot.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    color: isFavorite ? theme.colorScheme.error : null,
                    onPressed: onToggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(lot.address, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 16, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(formatEstimatedFee(recommendation.estimatedFee)),
                  const SizedBox(width: 16),
                  Icon(Icons.directions_walk, size: 16, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text('${formatDistanceMeters(recommendation.walkingDistanceMeters)} (직선거리)'),
                ],
              ),
              if (recommendation.reasons.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: recommendation.reasons
                      .map((reason) => Chip(
                            label: Text(reason, style: theme.textTheme.labelSmall),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
