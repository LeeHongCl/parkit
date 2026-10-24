import 'package:flutter/material.dart';

import '../providers/parking_recommend_providers.dart';

class ConditionPanel extends StatelessWidget {
  final int radius;
  final ValueChanged<int> onRadiusChanged;
  final int durationMinutes;
  final ValueChanged<int> onDurationChanged;
  final DateTime? arrivalAt;
  final ValueChanged<DateTime?> onArrivalAtChanged;
  final RecommendWeights weights;
  final ValueChanged<double> onFeeWeightChanged;
  final ValueChanged<double> onDistanceWeightChanged;
  final ValueChanged<double> onEvWeightChanged;
  final VoidCallback onSubmit;

  const ConditionPanel({
    super.key,
    required this.radius,
    required this.onRadiusChanged,
    required this.durationMinutes,
    required this.onDurationChanged,
    required this.arrivalAt,
    required this.onArrivalAtChanged,
    required this.weights,
    required this.onFeeWeightChanged,
    required this.onDistanceWeightChanged,
    required this.onEvWeightChanged,
    required this.onSubmit,
  });

  static const _durationOptions = [30, 60, 120, 180, 240, 360, 480, 720];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('검색 반경 (${radius}m)', style: theme.textTheme.labelLarge),
          Slider(
            value: radius.toDouble(),
            min: 100,
            max: 2000,
            divisions: 19,
            label: '${radius}m',
            onChanged: (value) => onRadiusChanged(value.round()),
          ),
          const SizedBox(height: 8),
          Text('예상 주차 시간', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _durationOptions.map((value) {
              final label = value < 60 ? '$value분' : '${value ~/ 60}시간';
              return ChoiceChip(
                label: Text(label),
                selected: durationMinutes == value,
                onSelected: (_) => onDurationChanged(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('도착 예정 시각', style: theme.textTheme.labelLarge),
              ),
              TextButton.icon(
                onPressed: () => _pickArrivalAt(context),
                icon: const Icon(Icons.schedule),
                label: Text(arrivalAt == null ? '지금' : _formatArrival(arrivalAt!)),
              ),
              if (arrivalAt != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: '지금으로 되돌리기',
                  onPressed: () => onArrivalAtChanged(null),
                ),
            ],
          ),
          const Divider(height: 24),
          Text('요금 중요도', style: theme.textTheme.labelLarge),
          Slider(value: weights.fee, min: 0, max: 1, divisions: 10, onChanged: onFeeWeightChanged),
          Text('거리 중요도', style: theme.textTheme.labelLarge),
          Slider(
            value: weights.distance,
            min: 0,
            max: 1,
            divisions: 10,
            onChanged: onDistanceWeightChanged,
          ),
          Text('전기차 충전 중요도', style: theme.textTheme.labelLarge),
          Slider(value: weights.ev, min: 0, max: 1, divisions: 10, onChanged: onEvWeightChanged),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: weights.hasAnyPositive ? onSubmit : null,
            icon: const Icon(Icons.search),
            label: const Text('추천 받기'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
          if (!weights.hasAnyPositive)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '요금·거리·전기차 중요도 중 하나는 0보다 커야 합니다.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  String _formatArrival(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.month}/${local.day} '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _pickArrivalAt(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: arrivalAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(arrivalAt ?? now),
    );
    if (time == null) return;

    onArrivalAtChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }
}
