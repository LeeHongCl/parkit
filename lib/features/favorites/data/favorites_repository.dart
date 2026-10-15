import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  static const _key = 'favorite_parking_lot_ids';

  final SharedPreferences prefs;
  FavoritesRepository(this.prefs);

  Set<String> getFavoriteIds() => (prefs.getStringList(_key) ?? const []).toSet();

  Future<void> setFavoriteIds(Set<String> ids) async {
    await prefs.setStringList(_key, ids.toList());
  }
}
