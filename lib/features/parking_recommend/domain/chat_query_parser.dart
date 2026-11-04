import '../data/daegu_landmarks.dart';
import '../data/models/lat_lng_point.dart';
import 'recommend_weights.dart';

/// 백엔드의 자연어 조건 입력 API는 아직 없다(명세 6장: "모델 선정 중이며
/// 엔드포인트 미구현"). 실제 LLM을 호출하는 대신, 지점 이름과 몇 가지
/// 키워드만 규칙 기반으로 해석해 기존 recommend API 파라미터로 바꾼다.
class ParsedChatQuery {
  final LatLngPoint center;
  final String? matchedLandmarkName;
  final RecommendWeights weights;
  final int durationMinutes;

  const ParsedChatQuery({
    required this.center,
    required this.matchedLandmarkName,
    required this.weights,
    required this.durationMinutes,
  });
}

ParsedChatQuery parseChatQuery(
  String text, {
  required LatLngPoint fallbackCenter,
  required RecommendWeights fallbackWeights,
  required int fallbackDurationMinutes,
}) {
  DaeguLandmark? matched;
  for (final landmark in daeguSearchableLandmarks) {
    if (text.contains(landmark.name)) {
      matched = landmark;
      break;
    }
  }

  final wantsFee = _containsAny(text, const ['저렴', '싸', '요금', '가격']);
  final wantsDistance = _containsAny(text, const ['가까운', '가까이', '근처', '도보']);
  final wantsEv = _containsAny(text, const ['전기차', '충전']);

  var weights = fallbackWeights;
  if (wantsFee || wantsDistance || wantsEv) {
    weights = RecommendWeights(
      fee: wantsFee ? 0.6 : 0.2,
      distance: wantsDistance ? 0.6 : 0.2,
      ev: wantsEv ? 0.4 : 0.05,
    );
  }

  var duration = fallbackDurationMinutes;
  final hourMatch = RegExp(r'(\d+)\s*시간').firstMatch(text);
  final minuteMatch = RegExp(r'(\d+)\s*분').firstMatch(text);
  if (hourMatch != null) {
    duration = int.parse(hourMatch.group(1)!) * 60;
  } else if (minuteMatch != null) {
    duration = int.parse(minuteMatch.group(1)!);
  }
  duration = duration.clamp(10, 2880);

  return ParsedChatQuery(
    center: matched?.point ?? fallbackCenter,
    matchedLandmarkName: matched?.name,
    weights: weights,
    durationMinutes: duration,
  );
}

bool _containsAny(String text, List<String> keywords) =>
    keywords.any((k) => text.contains(k));
