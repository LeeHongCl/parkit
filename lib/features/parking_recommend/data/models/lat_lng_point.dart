class LatLngPoint {
  final double lat;
  final double lng;

  const LatLngPoint({required this.lat, required this.lng});

  factory LatLngPoint.fromJson(Map<String, dynamic> json) => LatLngPoint(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      other is LatLngPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}
