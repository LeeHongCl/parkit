import 'lat_lng_point.dart';
import 'recommend_item.dart';

/// 즐겨찾기로 저장되는 최소 식별 정보. rank/score/reasons처럼 특정 검색
/// 맥락에서만 의미 있는 값은 저장하지 않는다(다시 볼 때는 해당 좌표를
/// 중심으로 recommend를 다시 호출해 최신 정보를 가져온다).
class FavoriteParkingLot {
  final int id;
  final String name;
  final String? address;
  final LatLngPoint location;

  const FavoriteParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
  });

  factory FavoriteParkingLot.fromRecommendItem(RecommendItem item) => FavoriteParkingLot(
        id: item.id,
        name: item.name,
        address: item.address,
        location: item.location,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'lat': location.lat,
        'lng': location.lng,
      };

  factory FavoriteParkingLot.fromJson(Map<String, dynamic> json) => FavoriteParkingLot(
        id: json['id'] as int,
        name: json['name'] as String,
        address: json['address'] as String?,
        location: LatLngPoint(lat: (json['lat'] as num).toDouble(), lng: (json['lng'] as num).toDouble()),
      );
}
