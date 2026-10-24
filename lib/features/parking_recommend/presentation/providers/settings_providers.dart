import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/shared_preferences_provider.dart';
import '../../domain/recommend_weights.dart';

class DefaultWeightsNotifier extends Notifier<RecommendWeights> {
  static const _feeKey = 'default_weight_fee';
  static const _distanceKey = 'default_weight_distance';
  static const _evKey = 'default_weight_ev';

  @override
  RecommendWeights build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return RecommendWeights(
      fee: prefs.getDouble(_feeKey) ?? 0.4,
      distance: prefs.getDouble(_distanceKey) ?? 0.3,
      ev: prefs.getDouble(_evKey) ?? 0.1,
    );
  }

  Future<void> _persist(SharedPreferences prefs) async {
    await prefs.setDouble(_feeKey, state.fee);
    await prefs.setDouble(_distanceKey, state.distance);
    await prefs.setDouble(_evKey, state.ev);
  }

  Future<void> setFee(double value) async {
    state = state.copyWith(fee: value);
    await _persist(ref.read(sharedPreferencesProvider));
  }

  Future<void> setDistance(double value) async {
    state = state.copyWith(distance: value);
    await _persist(ref.read(sharedPreferencesProvider));
  }

  Future<void> setEv(double value) async {
    state = state.copyWith(ev: value);
    await _persist(ref.read(sharedPreferencesProvider));
  }
}

final defaultWeightsProvider = NotifierProvider<DefaultWeightsNotifier, RecommendWeights>(
  DefaultWeightsNotifier.new,
);
