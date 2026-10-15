import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../recommendation/domain/recommendation_type.dart';

class DefaultRecommendationTypeNotifier extends Notifier<RecommendationType> {
  static const _key = 'default_recommendation_type';

  @override
  RecommendationType build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    return RecommendationType.values.firstWhere(
      (type) => type.name == stored,
      orElse: () => RecommendationType.balanced,
    );
  }

  Future<void> update(RecommendationType type) async {
    state = type;
    await ref.read(sharedPreferencesProvider).setString(_key, type.name);
  }
}

final defaultRecommendationTypeProvider =
    NotifierProvider<DefaultRecommendationTypeNotifier, RecommendationType>(
  DefaultRecommendationTypeNotifier.new,
);
