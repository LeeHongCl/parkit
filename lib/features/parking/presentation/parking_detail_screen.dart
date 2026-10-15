import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/format_utils.dart';
import '../../favorites/presentation/providers/favorites_providers.dart';
import '../domain/parking_fee_calculator.dart';
import 'providers/parking_providers.dart';

class ParkingDetailScreen extends ConsumerStatefulWidget {
  final String parkingLotId;
  const ParkingDetailScreen({super.key, required this.parkingLotId});

  @override
  ConsumerState<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends ConsumerState<ParkingDetailScreen> {
  int _durationMinutes = 180;

  static const _durationOptions = [30, 60, 120, 180, 240, 360];

  @override
  Widget build(BuildContext context) {
    final lotAsync = ref.watch(parkingLotByIdProvider(widget.parkingLotId));
    final favoriteIds = ref.watch(favoriteIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('주차장 상세')),
      body: lotAsync.when(
        data: (lot) {
          if (lot == null) {
            return const Center(child: Text('주차장 정보를 찾을 수 없습니다.'));
          }
          final isFavorite = favoriteIds.contains(lot.id);
          final estimatedFee = calculateEstimatedFee(lot, _durationMinutes);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(lot.name, style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    color: isFavorite ? Theme.of(context).colorScheme.error : null,
                    onPressed: () => ref.read(favoriteIdsProvider.notifier).toggle(lot.id),
                  ),
                ],
              ),
              Text(lot.address, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              _InfoRow(label: '구분', value: lot.parkingType.label),
              _InfoRow(label: '운영시간', value: lot.operatingHours ?? '정보 없음'),
              _InfoRow(
                label: '실시간 잔여면',
                value: lot.hasRealtimeAvailability
                    ? '${lot.availableSpaces}면 / 총 ${lot.capacity ?? '-'}면'
                    : '실시간 정보 미제공',
              ),
              const Divider(height: 32),
              Text('예상 요금 계산', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _durationOptions.map((value) {
                  final label = value < 60 ? '$value분' : '${value ~/ 60}시간';
                  return ChoiceChip(
                    label: Text(label),
                    selected: _durationMinutes == value,
                    onSelected: (_) => setState(() => _durationMinutes = value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                formatEstimatedFee(estimatedFee),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (lot.baseFee != null) ...[
                const SizedBox(height: 8),
                Text(
                  '기본 ${lot.baseMinutes}분 ${formatWon(lot.baseFee!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (lot.additionalFee != null && lot.additionalMinutes != null)
                  Text(
                    '추가 ${lot.additionalMinutes}분당 ${formatWon(lot.additionalFee!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (lot.dailyMaxFee != null)
                  Text(
                    '일 최대 ${formatWon(lot.dailyMaxFee!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
              const Divider(height: 32),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('길찾기 연동은 지도 SDK 적용 후 제공됩니다.')),
                  );
                },
                icon: const Icon(Icons.directions),
                label: const Text('길찾기'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류가 발생했습니다.\n$error')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
