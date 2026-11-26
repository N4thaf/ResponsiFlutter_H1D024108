import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../services/storage_service.dart';

class FavoriteViewModel extends ChangeNotifier {
  FavoriteViewModel(this._storage);

  final StorageService _storage;
  List<Location> _favorites = [];

  UnmodifiableListView<Location> get favorites => UnmodifiableListView(_favorites);

  Future<void> load() async {
    _favorites = await _storage.getFavorites();
    notifyListeners();
  }

  bool isFavorite(Location location) => _favorites.contains(location);

  Future<bool> toggle(Location location) async {
    final added = !isFavorite(location);
    if (added) {
      _favorites = [location, ..._favorites];
    } else {
      _favorites = _favorites.where((e) => e != location).toList();
    }
    notifyListeners();
    await _storage.saveFavorites(_favorites);
    return added;
  }
}
