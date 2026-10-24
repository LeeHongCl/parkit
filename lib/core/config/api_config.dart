import 'package:flutter/foundation.dart';

/// 빌드 시 --dart-define=API_BASE=http://... 로 재정의 가능.
/// 미지정 시 안드로이드 에뮬레이터는 10.0.2.2, 그 외는 localhost를 기본값으로 사용한다.
const _apiBaseOverride = String.fromEnvironment('API_BASE');

String resolveApiBase() {
  if (_apiBaseOverride.isNotEmpty) return _apiBaseOverride;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8100';
  }
  return 'http://localhost:8100';
}
