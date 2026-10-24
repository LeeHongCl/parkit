import 'package:geolocator/geolocator.dart';

import '../constants/daegu_bounds.dart';

class LocationResult {
  final double? lat;
  final double? lng;
  final String? errorMessage;

  const LocationResult({this.lat, this.lng, this.errorMessage});

  bool get isSuccess => errorMessage == null && lat != null && lng != null;
}

class LocationService {
  Future<LocationResult> getCurrentDaeguPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(errorMessage: '위치 서비스가 꺼져 있습니다.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return const LocationResult(errorMessage: '위치 권한이 필요합니다.');
    }

    final position = await Geolocator.getCurrentPosition();
    if (!DaeguBounds.contains(position.latitude, position.longitude)) {
      return const LocationResult(errorMessage: '현재 위치가 대구 지역 밖이라 이동하지 않았습니다.');
    }
    return LocationResult(lat: position.latitude, lng: position.longitude);
  }
}
