import 'parking_lot.dart';

/// 요금 정보가 없으면 null을 반환한다. 임의의 값을 추정해서 채우지 않는다.
int? calculateEstimatedFee(ParkingLot lot, int parkingMinutes) {
  if (lot.isFree) return 0;

  final baseFee = lot.baseFee;
  final baseMinutes = lot.baseMinutes;
  if (baseFee == null || baseMinutes == null) return null;

  if (parkingMinutes <= baseMinutes) {
    return _capAtDailyMax(lot, baseFee);
  }

  final extraMinutes = parkingMinutes - baseMinutes;
  final additionalFee = lot.additionalFee;
  final additionalMinutes = lot.additionalMinutes;
  if (additionalFee == null || additionalMinutes == null || additionalMinutes <= 0) {
    return _capAtDailyMax(lot, baseFee);
  }

  final additionalUnits = (extraMinutes / additionalMinutes).ceil();
  final total = baseFee + additionalUnits * additionalFee;
  return _capAtDailyMax(lot, total);
}

int _capAtDailyMax(ParkingLot lot, int fee) {
  final dailyMaxFee = lot.dailyMaxFee;
  if (dailyMaxFee != null && fee > dailyMaxFee) return dailyMaxFee;
  return fee;
}
