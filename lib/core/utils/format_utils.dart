import 'package:intl/intl.dart';

final _wonFormat = NumberFormat.decimalPattern('ko_KR');

String formatWon(int amount) => '${_wonFormat.format(amount)}원';

String formatEstimatedFee(int? amount) {
  if (amount == null) return '요금 정보 없음';
  if (amount == 0) return '무료';
  return formatWon(amount);
}

String formatDistanceMeters(double? meters) {
  if (meters == null) return '거리 정보 없음';
  if (meters < 1000) return '${meters.round()}m';
  return '${(meters / 1000).toStringAsFixed(1)}km';
}
