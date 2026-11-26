import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../services/storage_service.dart';
import '../services/weather_api_service.dart';
import 'view_state.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._api, this._storage);

  final WeatherApiService _api;
  final StorageService _storage;

  static const _maxHistory = 10;
  static const _debounceDuration = Duration(milliseconds: 450);

  String _query = '';
  List<Location> _results = [];
  List<Location> _history = [];
  ViewState _state = ViewState.initial;
  String? _errorMessage;

  Timer? _debounce;
  int _requestId = 0;

  String get query => _query;
  UnmodifiableListView<Location> get results => UnmodifiableListView(_results);
  UnmodifiableListView<Location> get history => UnmodifiableListView(_history);
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistory() async {
    _history = await _storage.getHistory();
    notifyListeners();
  }

  void onQueryChanged(String value) {
    _query = value.trim();
    _debounce?.cancel();

    if (_query.length < 2) {
      _requestId++;
      _results = [];
      _state = ViewState.initial;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();
    _debounce = Timer(_debounceDuration, search);
  }

  Future<void> search() async {
    _debounce?.cancel();
    if (_query.length < 2) return;

    final requestId = ++_requestId;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _api.searchCity(_query);
      if (requestId != _requestId) return;
      _results = results;
      _state = results.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiException catch (e) {
      if (requestId != _requestId) return;
      _errorMessage = e.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> addToHistory(Location location) async {
    _history = [location, ..._history.where((e) => e != location)].take(_maxHistory).toList();
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  Future<void> removeFromHistory(Location location) async {
    _history = _history.where((e) => e != location).toList();
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
