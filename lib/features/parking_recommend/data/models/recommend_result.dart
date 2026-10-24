import 'recommend_item.dart';

class RecommendExcluded {
  final int closed;
  final int unavailable;

  const RecommendExcluded({required this.closed, required this.unavailable});

  factory RecommendExcluded.fromJson(Map<String, dynamic>? json) => RecommendExcluded(
        closed: json?['closed'] as int? ?? 0,
        unavailable: json?['unavailable'] as int? ?? 0,
      );
}

class RecommendResult {
  final int count;
  final List<RecommendItem> items;
  final List<String> notes;
  final String arrivalAt;
  final RecommendExcluded excluded;

  const RecommendResult({
    required this.count,
    required this.items,
    required this.notes,
    required this.arrivalAt,
    required this.excluded,
  });

  factory RecommendResult.fromJson(Map<String, dynamic> json) => RecommendResult(
        count: json['count'] as int,
        items: (json['items'] as List)
            .map((e) => RecommendItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: ((json['notes'] as List?) ?? const []).map((e) => e as String).toList(),
        arrivalAt: json['arrival_at'] as String,
        excluded: RecommendExcluded.fromJson(json['excluded'] as Map<String, dynamic>?),
      );
}
