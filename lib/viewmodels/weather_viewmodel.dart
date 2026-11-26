import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../models/weather.dart';
import '../services/storage_service.dart';
import '../services/weather_api_service.dart';
import 'view_state.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._api, this._storage);

  final WeatherApiService _api;
  final StorageService _storage;

  Location? _location;
  WeatherData? _weather;
  ViewState _state = ViewState.initial;
  String? _errorMessage;

  Location? get location => _location;
  WeatherData? get weather => _weather;
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _location = await _storage.getLastLocation() ?? Location.defaultCity;
    notifyListeners();
    await fetchWeather();
  }

  Future<void> selectLocation(Location location) async {
    if (location == _location && _state == ViewState.success) return;
    _location = location;
    _weather = null;
    await _storage.saveLastLocation(location);
    await fetchWeather();
  }

  Future<void> fetchWeather() async {
    final location = _location;
    if (location == null) return;

    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.getWeather(location.latitude, location.longitude);
      if (!identical(location, _location)) return;

      _weather = data;
      _state = data.daily.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiException catch (e) {
      if (!identical(location, _location)) return;
      _errorMessage = e.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<String?> refresh() async {
    final location = _location;
    if (location == null) return null;
    if (_weather == null) {
      await fetchWeather();
      return null;
    }

    try {
      final data = await _api.getWeather(location.latitude, location.longitude);
      if (!identical(location, _location)) return null;
      _weather = data;
      _state = data.daily.isEmpty ? ViewState.empty : ViewState.success;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
