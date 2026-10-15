import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parkit/app/app.dart';
import 'package:parkit/core/providers/shared_preferences_provider.dart';

void main() {
  testWidgets('PARKIT 앱이 정상적으로 빌드되고 스플래시 화면이 보인다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const ParkitApp(),
      ),
    );

    expect(find.text('PARKIT'), findsWidgets);
  });
}
