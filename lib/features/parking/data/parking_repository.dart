import '../../../core/utils/distance_calculator.dart';
import '../domain/parking_lot.dart';
import 'mock_parking_lots.dart';

abstract class ParkingRepository {
  Future<List<ParkingLot>> getNearbyParkingLots({
    required double latitude,
    required double longitude,
    double radiusMeters = 1500,
  });

  Future<ParkingLot?> getParkingLotById(String id);

  Future<List<ParkingLot>> getParkingLotsByIds(List<String> ids);
}

/// 백엔드 API가 확정되기 전까지 사용하는 Mock 구현체.
/// 실제 API 연동 시 이 클래스만 교체하면 되도록 ParkingRepository 인터페이스에만 의존한다.
class MockParkingRepository implements ParkingRepository {
  @override
  Future<List<ParkingLot>> getNearbyParkingLots({
    required double latitude,
    required double longitude,
    double radiusMeters = 1500,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockParkingLots.where((lot) {
      final distance = calculateStraightLineDistanceMeters(
        startLatitude: latitude,
        startLongitude: longitude,
        endLatitude: lot.latitude,
        endLongitude: lot.longitude,
      );
      return distance <= radiusMeters;
    }).toList();
  }

  @override
  Future<ParkingLot?> getParkingLotById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return mockParkingLots.firstWhere((lot) => lot.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ParkingLot>> getParkingLotsByIds(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return mockParkingLots.where((lot) => ids.contains(lot.id)).toList();
  }
}
