import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location.dart';
import '../models/weather.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _geocodingHost = 'geocoding-api.open-meteo.com';
  static const _forecastHost = 'api.open-meteo.com';
  static const _timeout = Duration(seconds: 15);

  static const _currentFields = [
    'temperature_2m',
    'relative_humidity_2m',
    'apparent_temperature',
    'precipitation',
    'weather_code',
    'wind_speed_10m',
    'is_day',
  ];

  static const _hourlyFields = [
    'temperature_2m',
    'weather_code',
    'precipitation_probability',
  ];

  static const _dailyFields = [
    'weather_code',
    'temperature_2m_max',
    'temperature_2m_min',
    'precipitation_probability_max',
    'sunrise',
    'sunset',
    'uv_index_max',
  ];

  Future<List<Location>> searchCity(String name) async {
    final uri = Uri.https(_geocodingHost, '/v1/search', {
      'name': name,
      'count': '15',
      'language': 'id',
      'format': 'json',
    });

    final json = await _get(uri);
    final results = json['results'] as List<dynamic>?;
    if (results == null) return [];

    return results
        .map((e) => Location.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WeatherData> getWeather(double latitude, double longitude) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': _currentFields.join(','),
      'hourly': _hourlyFields.join(','),
      'daily': _dailyFields.join(','),
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final json = await _get(uri);
    return WeatherData.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on SocketException {
      throw const ApiException('Tidak ada koneksi internet. Cek jaringanmu lalu coba lagi.');
    } on http.ClientException {
      throw const ApiException('Tidak bisa terhubung ke server. Coba lagi nanti.');
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi sebentar.');
    }

    if (response.statusCode != 200) {
      var reason = 'Terjadi kesalahan pada server (${response.statusCode}).';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['reason'] != null) reason = body['reason'].toString();
      } on FormatException {
        reason = 'Terjadi kesalahan pada server (${response.statusCode}).';
      }
      throw ApiException(reason);
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException('Data dari server tidak bisa dibaca.');
    }
  }
}
