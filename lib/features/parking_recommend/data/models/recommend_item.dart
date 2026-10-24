import 'ev_info.dart';
import 'fee_structure.dart';
import 'hours_info.dart';
import 'lat_lng_point.dart';
import 'roadside_info.dart';

/// GET /api/v1/parking/recommend 의 items[] 항목.
/// score/parts는 화면에 표시하지 않으므로(명세 5번) 파싱하지 않는다.
class RecommendItem {
  final int id;
  final String name;
  final String? address;
  final String? gu;
  final bool? isPublic;
  final String access; // open | customers_only | unknown
  final String? accessNote;
  final int? capacity;
  final int distanceM;
  final bool feeKnown;
  final String feeStatus; // free | paid | incomplete | unknown
  final int? estimatedFee;
  final FeeStructure fee;
  final HoursInfo? hours;
  final String? note;
  final LatLngPoint location;
  final EvInfo ev;
  final RoadsideInfo roadside;
  final String source;
  final int rank;
  final String feeInfo; // complete | incomplete | unknown
  final String hoursInfo; // open | unknown
  final List<String> reasons;

  const RecommendItem({
    required this.id,
    required this.name,
    required this.address,
    required this.gu,
    required this.isPublic,
    required this.access,
    required this.accessNote,
    required this.capacity,
    required this.distanceM,
    required this.feeKnown,
    required this.feeStatus,
    required this.estimatedFee,
    required this.fee,
    required this.hours,
    required this.note,
    required this.location,
    required this.ev,
    required this.roadside,
    required this.source,
    required this.rank,
    required this.feeInfo,
    required this.hoursInfo,
    required this.reasons,
  });

  factory RecommendItem.fromJson(Map<String, dynamic> json) => RecommendItem(
        id: json['id'] as int,
        name: json['name'] as String,
        address: json['address'] as String?,
        gu: json['gu'] as String?,
        isPublic: json['is_public'] as bool?,
        access: json['access'] as String,
        accessNote: json['access_note'] as String?,
        capacity: json['capacity'] as int?,
        distanceM: json['distance_m'] as int,
        feeKnown: json['fee_known'] as bool,
        feeStatus: json['fee_status'] as String,
        estimatedFee: json['estimated_fee'] as int?,
        fee: FeeStructure.fromJson(json['fee'] as Map<String, dynamic>),
        hours: HoursInfo.fromJson(json['hours']),
        note: json['note'] as String?,
        location: LatLngPoint.fromJson(json['location'] as Map<String, dynamic>),
        ev: EvInfo.fromJson(json['ev'] as Map<String, dynamic>),
        roadside: RoadsideInfo.fromJson(json['roadside'] as Map<String, dynamic>),
        source: json['source'] as String,
        rank: json['rank'] as int,
        feeInfo: json['fee_info'] as String,
        hoursInfo: json['hours_info'] as String,
        reasons: ((json['reasons'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
      );
}
