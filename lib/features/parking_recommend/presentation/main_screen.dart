import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_service.dart';
import '../data/daegu_landmarks.dart';
import '../data/models/lat_lng_point.dart';
import '../data/parking_api_client.dart';
import 'providers/favorites_providers.dart';
import 'providers/parking_recommend_providers.dart';
import 'widgets/condition_panel.dart';
import 'widgets/parking_map.dart';
import 'widgets/result_card.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final _locationService = LocationService();
  final Map<int, GlobalKey> _cardKeys = {};
  bool _locating = false;

  @override
  Widget build(BuildContext context) {
    final center = ref.watch(searchCenterProvider);
    final radius = ref.watch(radiusMetersProvider);
    final duration = ref.watch(durationMinutesProvider);
    final arrivalAt = ref.watch(arrivalAtProvider);
    final weights = ref.watch(weightsProvider);
    final mapExpanded = ref.watch(mapExpandedProvider);
    final roadEnabled = ref.watch(roadOverlayEnabledProvider);
    final roadAsync = ref.watch(roadNearbyResultProvider);
    final recommendAsync = ref.watch(recommendResultProvider);
    final selectedId = ref.watch(selectedResultIdProvider);
    final metaAsync = ref.watch(metaResultProvider);

    ref.listen(selectedResultIdProvider, (previous, next) {
      if (next == null) return;
      final key = _cardKeys[next];
      final context = key?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300));
      }
    });

    final items = recommendAsync.value?.items ?? const [];
    _cardKeys
      ..removeWhere((id, _) => items.every((item) => item.id != id))
      ..addEntries(items.where((item) => !_cardKeys.containsKey(item.id)).map(
            (item) => MapEntry(item.id, GlobalKey()),
          ));

    return Scaffold(
      appBar: AppBar(title: const Text('PARKIT')),
      body: Column(
        children: [
          Stack(
            children: [
              ParkingMap(
                center: center,
                radiusMeters: radius,
                items: items,
                selectedId: selectedId,
                roadResult: roadAsync.value,
                height: mapExpanded ? 460 : 280,
                onTapMap: (point) => ref.read(searchCenterProvider.notifier).set(point),
                onSelectItem: (id) => ref.read(selectedResultIdProvider.notifier).select(id),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Column(
                  children: [
                    _MapIconButton(
                      icon: mapExpanded ? Icons.unfold_less : Icons.unfold_more,
                      tooltip: '지도 크기 전환',
                      onPressed: () => ref.read(mapExpandedProvider.notifier).toggle(),
                    ),
                    const SizedBox(height: 8),
                    _MapIconButton(
                      icon: Icons.my_location,
                      tooltip: '현재 위치로 이동',
                      loading: _locating,
                      onPressed: _locating ? null : _moveToCurrentLocation,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: FilterChip(
                  label: Text(
                    roadEnabled
                        ? '노상주차 ${roadAsync.value?.totalSpots ?? ''}'
                        : '노상주차·단속카메라',
                  ),
                  selected: roadEnabled,
                  onSelected: (_) => ref.read(roadOverlayEnabledProvider.notifier).toggle(),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: daeguQuickJumpLandmarks.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final landmark = daeguQuickJumpLandmarks[index];
                      return ActionChip(
                        label: Text(landmark.name),
                        onPressed: () =>
                            ref.read(searchCenterProvider.notifier).set(landmark.point),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ConditionPanel(
                  radius: radius,
                  onRadiusChanged: (value) => ref.read(radiusMetersProvider.notifier).set(value),
                  durationMinutes: duration,
                  onDurationChanged: (value) =>
                      ref.read(durationMinutesProvider.notifier).set(value),
                  arrivalAt: arrivalAt,
                  onArrivalAtChanged: (value) => ref.read(arrivalAtProvider.notifier).set(value),
                  weights: weights,
                  onFeeWeightChanged: (value) => ref.read(weightsProvider.notifier).setFee(value),
                  onDistanceWeightChanged: (value) =>
                      ref.read(weightsProvider.notifier).setDistance(value),
                  onEvWeightChanged: (value) => ref.read(weightsProvider.notifier).setEv(value),
                  onSubmit: () => ref.read(recommendParamsProvider.notifier).submit(),
                ),
                const Divider(height: 1),
                _ResultsSection(
                  recommendAsync: recommendAsync,
                  selectedId: selectedId,
                  cardKeys: _cardKeys,
                ),
                _MetaFooter(metaAsync: metaAsync),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() => _locating = true);
    final result = await _locationService.getCurrentDaeguPosition();
    if (!mounted) return;
    setState(() => _locating = false);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? '현재 위치를 가져오지 못했습니다.')),
      );
      return;
    }

    ref.read(searchCenterProvider.notifier).set(LatLngPoint(lat: result.lat!, lng: result.lng!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('현재 위치로 이동: ${result.lat!.toStringAsFixed(5)}, ${result.lng!.toStringAsFixed(5)}')),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool loading;

  const _MapIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
      ),
    );
  }
}

class _ResultsSection extends ConsumerWidget {
  final AsyncValue recommendAsync;
  final int? selectedId;
  final Map<int, GlobalKey> cardKeys;

  const _ResultsSection({
    required this.recommendAsync,
    required this.selectedId,
    required this.cardKeys,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataUpdatedDate = ref.watch(metaResultProvider).value?.displayDate;
    final favorites = ref.watch(favoritesProvider);
    return recommendAsync.when(
      data: (result) {
        if (result.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('조건에 맞는 주차장이 없습니다.')),
          );
        }
        return Column(
          children: [
            for (final item in result.items)
              Container(
                key: cardKeys[item.id],
                child: ResultCard(
                  item: item,
                  selected: selectedId == item.id,
                  isFavorite: favorites.any((f) => f.id == item.id),
                  onTap: () => ref.read(selectedResultIdProvider.notifier).select(item.id),
                  onToggleFavorite: () => ref.read(favoritesProvider.notifier).toggle(item),
                  onDetail: () => context.push('/detail', extra: {
                    'item': item,
                    'durationMinutes': ref.read(durationMinutesProvider),
                    'dataUpdatedDate': dataUpdatedDate,
                  }),
                ),
              ),
            if (result.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.notes
                      .map((note) => Text(
                            note,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ))
                      .toList(),
                ),
              ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              error is ApiException ? error.message : '알 수 없는 오류가 발생했습니다.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.read(recommendParamsProvider.notifier).submit(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaFooter extends StatelessWidget {
  final AsyncValue metaAsync;
  const _MetaFooter({required this.metaAsync});

  @override
  Widget build(BuildContext context) {
    final meta = metaAsync.value;
    final date = meta?.displayDate;
    if (date == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        '데이터 기준일: $date',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
    );
  }
}
