import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../search/domain/destination.dart';
import '../../../search/presentation/providers/search_providers.dart';
import '../../data/parking_repository.dart';
import '../../domain/parking_lot.dart';

final parkingRepositoryProvider = Provider<ParkingRepository>((ref) {
  return MockParkingRepository();
});

final nearbyParkingLotsProvider = FutureProvider.autoDispose<List<ParkingLot>>((ref) async {
  final destination = ref.watch(selectedDestinationProvider) ?? Destination.sample;
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.getNearbyParkingLots(
    latitude: destination.latitude,
    longitude: destination.longitude,
  );
});

final parkingLotByIdProvider =
    FutureProvider.autoDispose.family<ParkingLot?, String>((ref, id) async {
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.getParkingLotById(id);
});
