/// 서비스 지역(대구, 군위군 제외) 좌표 범위. 백엔드가 이 범위 밖 좌표를 400으로 거부하므로
/// 앱에서도 현재 위치 이동 등에서 동일한 범위로 사전 검증한다.
class DaeguBounds {
  static const double minLat = 35.5;
  static const double maxLat = 36.0;
  static const double minLng = 128.3;
  static const double maxLng = 128.85;

  static bool contains(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}
