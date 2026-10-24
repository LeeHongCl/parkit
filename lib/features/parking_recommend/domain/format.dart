import 'package:intl/intl.dart';

import '../data/models/hours_info.dart';
import '../data/models/recommend_item.dart';

final _wonFormat = NumberFormat.decimalPattern('ko_KR');

String formatWon(int amount) => '${_wonFormat.format(amount)}원';

/// 명세 5장 표시 규칙: 점수는 절대 노출하지 않고, 정보 없음을 비싸거나
/// 위험한 것처럼 보이지 않게 한다.
String formatEstimatedFee(RecommendItem item) {
  switch (item.feeStatus) {
    case 'free':
      return '무료';
    case 'paid':
      final fee = item.estimatedFee;
      return fee == null ? '요금 정보 없음' : '${formatWon(fee)} (예상 주차 시간 기준)';
    case 'incomplete':
      return '요금 정보가 불완전해 계산할 수 없음';
    case 'unknown':
    default:
      return '요금 정보 없음';
  }
}

String formatAccess(RecommendItem item) {
  final note = item.accessNote;
  switch (item.access) {
    case 'customers_only':
      return note == null ? '건물·상가 이용객 전용' : '건물·상가 이용객 전용 · $note';
    case 'unknown':
      return note == null ? '이용 조건 확인 필요' : '이용 조건 확인 필요 · $note';
    case 'open':
    default:
      return '일반 개방';
  }
}

String formatDayHours(DayHours? hours) {
  if (hours == null) return '정보 없음';
  return '${hours.open} - ${hours.close}';
}

String formatHoursSummary(RecommendItem item) {
  if (item.hours == null || item.hoursInfo == 'unknown') return '운영 시간 정보 없음';
  return '평일 ${formatDayHours(item.hours!.weekday)}';
}

String formatDistance(int meters) {
  if (meters < 1000) return '${meters}m';
  return '${(meters / 1000).toStringAsFixed(1)}km';
}
