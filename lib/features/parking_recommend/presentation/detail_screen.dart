import 'package:flutter/material.dart';

import '../data/models/recommend_item.dart';
import '../domain/format.dart';

/// 추천 응답에 이미 들어 있는 값으로만 그린다. 추가 API 호출은 하지 않는다(명세 4.4).
class DetailScreen extends StatelessWidget {
  final RecommendItem item;
  final int durationMinutes;
  final String? dataUpdatedDate;

  const DetailScreen({
    super.key,
    required this.item,
    required this.durationMinutes,
    required this.dataUpdatedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (item.address != null) Text(item.address!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text('예상 요금', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '$durationMinutes분 기준 · ${formatEstimatedFee(item)}',
            style: theme.textTheme.headlineSmall,
          ),
          const Text(
            '요금은 공공데이터 기준 예상치입니다. 실제 요금은 현장 안내를 확인하세요.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 32),
          Text('요금 구조', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _FeeStructureTable(item: item),
          const Divider(height: 32),
          Text('운영 시간', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (item.hours == null || item.hoursInfo == 'unknown')
            const Text('운영 시간 정보 없음')
          else ...[
            _InfoRow(label: '평일', value: formatDayHours(item.hours!.weekday)),
            _InfoRow(label: '토요일', value: formatDayHours(item.hours!.sat)),
            _InfoRow(label: '일요일', value: formatDayHours(item.hours!.sun)),
            _InfoRow(label: '공휴일', value: formatDayHours(item.hours!.holiday)),
          ],
          if (item.note != null) ...[
            const Divider(height: 32),
            Text('원본 안내', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(item.note!),
          ],
          const Divider(height: 32),
          Text('이용 조건', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(formatAccess(item)),
          const Divider(height: 32),
          Text('전기차 충전', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            item.ev.stations200m > 0
                ? '200m 이내 충전소 ${item.ev.stations200m}곳'
                    '${item.ev.maxKw != null ? ' · 최대 ${item.ev.maxKw}kW' : ''}'
                : '200m 이내 충전소 없음',
          ),
          const Divider(height: 32),
          Text('주변 노상주차 (참고)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '150m 이내 노상주차면 ${item.roadside.spots150m}개 · '
            '단속카메라 ${item.roadside.cameras150m}개',
          ),
          const Text(
            '만차 여부·단속 시간·유료/무료는 반영되지 않은 참고 정보입니다.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 32),
          _InfoRow(label: '데이터 출처', value: item.source),
          if (dataUpdatedDate != null) _InfoRow(label: '데이터 기준일', value: dataUpdatedDate!),
        ],
      ),
    );
  }
}

class _FeeStructureTable extends StatelessWidget {
  final RecommendItem item;
  const _FeeStructureTable({required this.item});

  @override
  Widget build(BuildContext context) {
    final fee = item.fee;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(label: '회차 시간', value: _minutesOrUnknown(fee.freeMinutes)),
        _InfoRow(
          label: '기본 요금',
          value: fee.baseFee == null || fee.baseMinutes == null
              ? '정보 없음'
              : '${fee.baseMinutes}분 ${formatWon(fee.baseFee!)}',
        ),
        _InfoRow(
          label: '추가 요금',
          value: fee.addFee == null || fee.addMinutes == null
              ? '정보 없음'
              : '${fee.addMinutes}분당 ${formatWon(fee.addFee!)}',
        ),
        _InfoRow(
          label: '일 최대',
          value: fee.dayMaxFee == null ? '정보 없음' : formatWon(fee.dayMaxFee!),
        ),
      ],
    );
  }

  String _minutesOrUnknown(int? minutes) => minutes == null ? '정보 없음' : '$minutes분';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
