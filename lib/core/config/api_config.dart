/// 빌드 시 --dart-define=API_BASE=http://... 로 재정의 가능 (예: 로컬 백엔드로 테스트할 때).
/// 미지정 시 배포된 실서버를 기본값으로 사용한다.
const _apiBaseOverride = String.fromEnvironment('API_BASE');
const _deployedApiBase = 'http://141.147.178.70:8100';

String resolveApiBase() {
  if (_apiBaseOverride.isNotEmpty) return _apiBaseOverride;
  return _deployedApiBase;
}
