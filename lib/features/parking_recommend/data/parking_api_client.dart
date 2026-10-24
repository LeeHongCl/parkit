import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import 'models/meta_result.dart';
import 'models/recommend_result.dart';
import 'models/road_nearby_result.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// 명세 3장(API 명세)에 정의된 recommend / road/nearby / meta 3개 엔드포인트만 호출한다.
/// search, health는 앱이 쓰지 않으므로 구현하지 않는다.
class ParkingApiClient {
  final Dio _dio;

  ParkingApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: '${resolveApiBase()}/api/v1',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ));

  Future<RecommendResult> fetchRecommend({
    required double lat,
    required double lng,
    int radius = 500,
    int durationMin = 120,
    DateTime? arrivalAt,
    double? wDistance,
    double? wFee,
    double? wEv,
    bool includeUnknown = false,
    bool destinationIsBuilding = false,
    int customersRadius = 100,
    bool excludeClosed = true,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get('/parking/recommend', queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radius,
        'duration_min': durationMin,
        if (arrivalAt != null) 'arrival_at': arrivalAt.toUtc().toIso8601String(),
        'w_distance': ?wDistance,
        'w_fee': ?wFee,
        'w_ev': ?wEv,
        'include_unknown': includeUnknown,
        'destination_is_building': destinationIsBuilding,
        'customers_radius': customersRadius,
        'exclude_closed': excludeClosed,
        'limit': limit,
      });
      return RecommendResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<RoadNearbyResult> fetchRoadNearby({
    required double lat,
    required double lng,
    int radius = 500,
    int limit = 600,
  }) async {
    try {
      final response = await _dio.get('/road/nearby', queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radius,
        'limit': limit,
      });
      return RoadNearbyResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<MetaResult> fetchMeta() async {
    try {
      final response = await _dio.get('/meta');
      return MetaResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return ApiException('서버에 연결할 수 없습니다. (${_dio.options.baseUrl})');
    }
    if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
      return ApiException('서버 응답이 없습니다. 서버가 켜져 있는지 확인하세요.');
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 400) {
      final data = e.response?.data;
      final detail = data is Map ? data['detail'] : null;
      return ApiException(detail?.toString() ?? '잘못된 요청입니다.');
    }
    return ApiException('서버 오류 ($statusCode)');
  }
}
