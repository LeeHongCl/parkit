import 'models/lat_lng_point.dart';

class DaeguLandmark {
  final String name;
  final LatLngPoint point;
  const DaeguLandmark({required this.name, required this.point});
}

/// 빠른 이동 목록(지도를 바로 옮길 대구 내 주요 지점).
const List<DaeguLandmark> daeguQuickJumpLandmarks = [
  DaeguLandmark(name: '대구시청', point: LatLngPoint(lat: 35.8714, lng: 128.6014)),
  DaeguLandmark(name: '동대구역', point: LatLngPoint(lat: 35.8795, lng: 128.6286)),
  DaeguLandmark(name: '동성로', point: LatLngPoint(lat: 35.8697, lng: 128.5946)),
  DaeguLandmark(name: '수성못', point: LatLngPoint(lat: 35.8273, lng: 128.6227)),
  DaeguLandmark(name: '대구국제공항', point: LatLngPoint(lat: 35.8939, lng: 128.6589)),
  DaeguLandmark(name: '계명대학교', point: LatLngPoint(lat: 35.8540, lng: 128.4910)),
];
