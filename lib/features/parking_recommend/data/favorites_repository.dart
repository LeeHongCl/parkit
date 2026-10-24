import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/favorite_parking_lot.dart';

class FavoritesRepository {
  static const _key = 'favorite_parking_lots';

  final SharedPreferences prefs;
  FavoritesRepository(this.prefs);

  List<FavoriteParkingLot> getFavorites() {
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((item) => FavoriteParkingLot.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<FavoriteParkingLot> favorites) async {
    await prefs.setStringList(_key, favorites.map((f) => jsonEncode(f.toJson())).toList());
  }
}
