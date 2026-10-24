import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lat_lng_point.dart';
import '../../data/models/meta_result.dart';
import '../../data/models/recommend_result.dart';
import '../../data/models/road_nearby_result.dart';
import '../../data/parking_api_client.dart';
import '../../domain/recommend_weights.dart';
import 'settings_providers.dart';

export '../../domain/recommend_weights.dart';

final parkingApiClientProvider = Provider<ParkingApiClient>((ref) => ParkingApiClient());

// --- 검색 중심 좌표 (지도 탭 / 빠른 이동 / 현재 위치로 갱신) ---
class SearchCenterNotifier extends Notifier<LatLngPoint> {
  @override
  LatLngPoint build() => const LatLngPoint(lat: 35.8714, lng: 128.6014); // 대구시청 기본값

  void set(LatLngPoint point) => state = point;
}

final searchCenterProvider = NotifierProvider<SearchCenterNotifier, LatLngPoint>(
  SearchCenterNotifier.new,
);

// --- 검색 반경(100~2000m), 지도의 반경 원 + road/nearby 오버레이에도 즉시 반영 ---
class RadiusMetersNotifier extends Notifier<int> {
  @override
  int build() => 500;

  void set(int value) => state = value.clamp(100, 2000);
}

final radiusMetersProvider = NotifierProvider<RadiusMetersNotifier, int>(
  RadiusMetersNotifier.new,
);

// --- 예상 주차 시간(분, 10~2880) ---
class DurationMinutesNotifier extends Notifier<int> {
  @override
  int build() => 120;

  void set(int value) => state = value.clamp(10, 2880);
}

final durationMinutesProvider = NotifierProvider<DurationMinutesNotifier, int>(
  DurationMinutesNotifier.new,
);

// --- 도착 예정 시각 (null = 지금) ---
class ArrivalAtNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void set(DateTime? value) => state = value;
}

final arrivalAtProvider = NotifierProvider<ArrivalAtNotifier, DateTime?>(
  ArrivalAtNotifier.new,
);

// --- 요금/거리/전기차 중요도 (서버가 비율로 정규화하므로 절대값 자체는 중요치 않음) ---
// 초기값은 설정 탭에서 저장한 기본 중요도를 사용한다.
class WeightsNotifier extends Notifier<RecommendWeights> {
  @override
  RecommendWeights build() => ref.read(defaultWeightsProvider);

  void setFee(double value) => state = state.copyWith(fee: value);
  void setDistance(double value) => state = state.copyWith(distance: value);
  void setEv(double value) => state = state.copyWith(ev: value);
}

final weightsProvider = NotifierProvider<WeightsNotifier, RecommendWeights>(
  WeightsNotifier.new,
);

// --- "추천 받기" 버튼을 눌렀을 때만 실제 요청 파라미터로 확정(스냅샷) ---
class RecommendParams {
  final LatLngPoint center;
  final int radius;
  final int durationMinutes;
  final DateTime? arrivalAt;
  final RecommendWeights weights;

  const RecommendParams({
    required this.center,
    required this.radius,
    required this.durationMinutes,
    required this.arrivalAt,
    required this.weights,
  });

  @override
  bool operator ==(Object other) =>
      other is RecommendParams &&
      other.center == center &&
      other.radius == radius &&
      other.durationMinutes == durationMinutes &&
      other.arrivalAt == arrivalAt &&
      other.weights == weights;

  @override
  int get hashCode => Object.hash(center, radius, durationMinutes, arrivalAt, weights);
}

class RecommendParamsNotifier extends Notifier<RecommendParams> {
  @override
  RecommendParams build() => _snapshot();

  RecommendParams _snapshot() => RecommendParams(
        center: ref.read(searchCenterProvider),
        radius: ref.read(radiusMetersProvider),
        durationMinutes: ref.read(durationMinutesProvider),
        arrivalAt: ref.read(arrivalAtProvider),
        weights: ref.read(weightsProvider),
      );

  void submit() => state = _snapshot();
}

final recommendParamsProvider = NotifierProvider<RecommendParamsNotifier, RecommendParams>(
  RecommendParamsNotifier.new,
);

// retry: null로 고정 — 명세 4.5의 에러 처리 규칙은 실패 시 즉시 에러 문구를 보여주고
// 사용자가 "다시 시도" 버튼을 눌러야 재요청하는 방식이다. Riverpod 3.x의 기본 자동
// 재시도(지수 백오프로 계속 재요청)를 켜두면 에러 문구 대신 로딩 상태가 계속 보이게 된다.
final recommendResultProvider = FutureProvider<RecommendResult>((ref) async {
  final params = ref.watch(recommendParamsProvider);
  final client = ref.watch(parkingApiClientProvider);
  return client.fetchRecommend(
    lat: params.center.lat,
    lng: params.center.lng,
    radius: params.radius,
    durationMin: params.durationMinutes,
    arrivalAt: params.arrivalAt,
    wFee: params.weights.fee,
    wDistance: params.weights.distance,
    wEv: params.weights.ev,
  );
}, retry: (retryCount, error) => null);

// --- 노상주차/단속카메라 오버레이 — 칩 토글 시 즉시 현재 지도 중심 기준으로 조회 ---
class RoadOverlayEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final roadOverlayEnabledProvider = NotifierProvider<RoadOverlayEnabledNotifier, bool>(
  RoadOverlayEnabledNotifier.new,
);

final roadNearbyResultProvider = FutureProvider<RoadNearbyResult?>((ref) async {
  final enabled = ref.watch(roadOverlayEnabledProvider);
  if (!enabled) return null;
  final center = ref.watch(searchCenterProvider);
  final radius = ref.watch(radiusMetersProvider);
  final client = ref.watch(parkingApiClientProvider);
  try {
    return await client.fetchRoadNearby(lat: center.lat, lng: center.lng, radius: radius);
  } catch (_) {
    // 명세 4.5: road/nearby 실패는 오류를 띄우지 않고 표시만 건너뛴다.
    return null;
  }
}, retry: (retryCount, error) => null);

// --- 데이터 기준일(meta) — 실패해도 조용히 건너뜀 ---
final metaResultProvider = FutureProvider<MetaResult?>((ref) async {
  final client = ref.watch(parkingApiClientProvider);
  try {
    return await client.fetchMeta();
  } catch (_) {
    return null;
  }
}, retry: (retryCount, error) => null);

// --- 지도 마커 ↔ 결과 카드 선택 동기화 ---
class SelectedResultIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? id) => state = id;
}

final selectedResultIdProvider = NotifierProvider<SelectedResultIdNotifier, int?>(
  SelectedResultIdNotifier.new,
);

// --- 지도 높이 토글(280 ↔ 460) ---
class MapExpandedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final mapExpandedProvider = NotifierProvider<MapExpandedNotifier, bool>(
  MapExpandedNotifier.new,
);
