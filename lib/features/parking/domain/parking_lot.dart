import 'parking_type.dart';

class ParkingLot {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final ParkingType parkingType;
  final bool isFree;
  final int? capacity;
  final int? availableSpaces;
  final DateTime? availabilityUpdatedAt;
  final int? baseFee;
  final int? baseMinutes;
  final int? additionalFee;
  final int? additionalMinutes;
  final int? dailyMaxFee;
  final String? operatingHours;

  const ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.parkingType,
    this.isFree = false,
    this.capacity,
    this.availableSpaces,
    this.availabilityUpdatedAt,
    this.baseFee,
    this.baseMinutes,
    this.additionalFee,
    this.additionalMinutes,
    this.dailyMaxFee,
    this.operatingHours,
  });

  bool get hasRealtimeAvailability => availableSpaces != null;

  bool get hasFeeInfo => isFree || (baseFee != null && baseMinutes != null);
}
