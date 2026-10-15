import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// main()에서 ProviderScope(overrides: [...])로 실제 SharedPreferences 인스턴스를 주입한다.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider가 main()에서 주입되지 않았습니다.');
});
