import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location.dart';

class StorageService {
  static const _favoritesKey = 'favorite_locations';
  static const _historyKey = 'search_history';
  static const _lastLocationKey = 'last_location';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Location>> getFavorites() => _readList(_favoritesKey);

  Future<void> saveFavorites(List<Location> locations) =>
      _writeList(_favoritesKey, locations);

  Future<List<Location>> getHistory() => _readList(_historyKey);

  Future<void> saveHistory(List<Location> locations) =>
      _writeList(_historyKey, locations);

  Future<Location?> getLastLocation() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null) return null;
    try {
      return Location.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastLocation(Location location) async {
    final prefs = await _prefs;
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  Future<List<Location>> _readList(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(key) ?? const [];
    final result = <Location>[];
    for (final item in raw) {
      try {
        result.add(Location.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {}
    }
    return result;
  }

  Future<void> _writeList(String key, List<Location> locations) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      key,
      locations.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
