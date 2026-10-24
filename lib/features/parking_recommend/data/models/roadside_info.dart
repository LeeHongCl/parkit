/// 참고용 개수일 뿐 위험도 점수가 아니다. 화면에 "위험도"로 표현하지 않는다.
class RoadsideInfo {
  final int spots150m;
  final int cameras150m;

  const RoadsideInfo({required this.spots150m, required this.cameras150m});

  factory RoadsideInfo.fromJson(Map<String, dynamic> json) => RoadsideInfo(
        spots150m: json['spots_150m'] as int,
        cameras150m: json['cameras_150m'] as int,
      );
}
