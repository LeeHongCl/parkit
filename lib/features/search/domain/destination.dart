class Destination {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const Destination({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  static const sample = Destination(
    name: '강남역',
    address: '서울 강남구 강남대로 396',
    latitude: 37.497952,
    longitude: 127.027619,
  );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
        name: json['name'] as String,
        address: json['address'] as String,
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
      );
}
