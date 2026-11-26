import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi_cuaca/models/location.dart';
import 'package:responsi_cuaca/models/weather.dart';
import 'package:responsi_cuaca/services/weather_api_service.dart';

void main() {
  final sampleForecast = {
    'latitude': -7.42,
    'longitude': 109.23,
    'timezone': 'Asia/Jakarta',
    'current': {
      'time': '2026-11-26T08:15',
      'temperature_2m': 26.1,
      'relative_humidity_2m': 87,
      'apparent_temperature': 31.8,
      'precipitation': 0.0,
      'weather_code': 2,
      'wind_speed_10m': 1.6,
      'is_day': 1,
    },
    'hourly': {
      'time': ['2026-11-26T07:00', '2026-11-26T08:00', '2026-11-26T09:00'],
      'temperature_2m': [25.0, 26.0, 27.5],
      'weather_code': [1, 2, 61],
      'precipitation_probability': [0, 10, null],
    },
    'daily': {
      'time': ['2026-11-26', '2026-11-27'],
      'weather_code': [61, 3],
      'temperature_2m_max': [31.2, 30.0],
      'temperature_2m_min': [23.4, 22.8],
      'precipitation_probability_max': [80, 45],
      'sunrise': ['2026-11-26T05:21', '2026-11-27T05:21'],
      'sunset': ['2026-11-26T17:48', '2026-11-27T17:49'],
      'uv_index_max': [9.1, 8.0],
    },
  };

  test('WeatherData.fromJson mengubah respons API jadi model', () {
    final data = WeatherData.fromJson(sampleForecast);

    expect(data.current.temperature, 26.1);
    expect(data.current.humidity, 87);
    expect(data.current.isDay, isTrue);
    expect(data.daily.length, 2);
    expect(data.today!.precipitationProbability, 80);
    expect(data.hourly.first.time.hour, 8);
    expect(data.hourly.last.precipitationProbability, isNull);
  });

  test('Location bisa disimpan lalu dibaca ulang lewat JSON', () {
    final restored = Location.fromJson(
      jsonDecode(jsonEncode(Location.defaultCity.toJson())) as Map<String, dynamic>,
    );
    expect(restored, Location.defaultCity);
    expect(restored.displayName, 'Purwokerto, Kabupaten Banyumas');
    expect(restored.subtitle, 'Jawa Tengah, Indonesia');
  });

  test('searchCity mengembalikan list kosong saat tidak ada hasil', () async {
    final api = WeatherApiService(
      client: MockClient((_) async => http.Response('{"generationtime_ms":0.1}', 200)),
    );
    expect(await api.searchCity('xyzxyz'), isEmpty);
  });

  test('error dari server diubah jadi ApiException', () async {
    final api = WeatherApiService(
      client: MockClient((_) async => http.Response('{"error":true,"reason":"Latitude salah"}', 400)),
    );
    expect(
      () => api.getWeather(999, 0),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Latitude salah')),
    );
  });
}
