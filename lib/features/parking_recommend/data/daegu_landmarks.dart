import 'models/lat_lng_point.dart';

class DaeguLandmark {
  final String name;
  final LatLngPoint point;
  const DaeguLandmark({required this.name, required this.point});
}

/// 빠른 이동 목록(홈 화면 가로 칩, 지도를 바로 옮길 대구 내 주요 지점).
const List<DaeguLandmark> daeguQuickJumpLandmarks = [
  DaeguLandmark(name: '대구시청', point: LatLngPoint(lat: 35.8714, lng: 128.6014)),
  DaeguLandmark(name: '동대구역', point: LatLngPoint(lat: 35.8795, lng: 128.6286)),
  DaeguLandmark(name: '동성로', point: LatLngPoint(lat: 35.8697, lng: 128.5946)),
  DaeguLandmark(name: '수성못', point: LatLngPoint(lat: 35.8273, lng: 128.6227)),
  DaeguLandmark(name: '대구국제공항', point: LatLngPoint(lat: 35.8939, lng: 128.6589)),
  DaeguLandmark(name: '계명대학교', point: LatLngPoint(lat: 35.8540, lng: 128.4910)),
];

/// 검색 탭에서 이름으로 필터링할 대구 내 지점 목록(백엔드 /search API는 쓰지 않는다).
const List<DaeguLandmark> daeguSearchableLandmarks = [
  ...daeguQuickJumpLandmarks,
  DaeguLandmark(name: '대구역', point: LatLngPoint(lat: 35.8737, lng: 128.5956)),
  DaeguLandmark(name: '반월당역', point: LatLngPoint(lat: 35.8657, lng: 128.5940)),
  DaeguLandmark(name: '범어역', point: LatLngPoint(lat: 35.8564, lng: 128.6279)),
  DaeguLandmark(name: '칠곡', point: LatLngPoint(lat: 35.9358, lng: 128.5636)),
  DaeguLandmark(name: '대구스타디움', point: LatLngPoint(lat: 35.9108, lng: 128.6619)),
  DaeguLandmark(name: '이월드', point: LatLngPoint(lat: 35.8557, lng: 128.5680)),
  DaeguLandmark(name: '팔공산', point: LatLngPoint(lat: 35.9558, lng: 128.6879)),
  DaeguLandmark(name: '서문시장', point: LatLngPoint(lat: 35.8706, lng: 128.5774)),
  DaeguLandmark(name: '경북대학교', point: LatLngPoint(lat: 35.8906, lng: 128.6107)),
  DaeguLandmark(name: '대구삼성창조캠퍼스', point: LatLngPoint(lat: 35.8629, lng: 128.5853)),
];
