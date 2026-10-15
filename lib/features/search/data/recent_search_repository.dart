import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/destination.dart';

class RecentSearchRepository {
  static const _key = 'recent_searches';
  static const _maxItems = 10;

  final SharedPreferences prefs;
  RecentSearchRepository(this.prefs);

  List<Destination> getRecentSearches() {
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((item) => Destination.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addRecentSearch(Destination destination) async {
    final current = getRecentSearches();
    current.removeWhere((d) => d.name == destination.name);
    current.insert(0, destination);
    final limited = current.take(_maxItems).toList();
    await prefs.setStringList(
      _key,
      limited.map((d) => jsonEncode(d.toJson())).toList(),
    );
  }

  Future<void> clearRecentSearches() async {
    await prefs.remove(_key);
  }
}
