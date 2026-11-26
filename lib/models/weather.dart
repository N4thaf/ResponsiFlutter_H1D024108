class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  DailyForecast? get today => daily.isEmpty ? null : daily.first;

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = CurrentWeather.fromJson(json['current'] as Map<String, dynamic>);

    final daily = <DailyForecast>[];
    final d = json['daily'] as Map<String, dynamic>?;
    if (d != null) {
      final times = List<String>.from(d['time'] ?? const []);
      for (var i = 0; i < times.length; i++) {
        daily.add(DailyForecast(
          date: DateTime.parse(times[i]),
          weatherCode: _intAt(d['weather_code'], i) ?? 0,
          maxTemp: _doubleAt(d['temperature_2m_max'], i) ?? 0,
          minTemp: _doubleAt(d['temperature_2m_min'], i) ?? 0,
          precipitationProbability: _intAt(d['precipitation_probability_max'], i),
          sunrise: _dateAt(d['sunrise'], i),
          sunset: _dateAt(d['sunset'], i),
          uvIndexMax: _doubleAt(d['uv_index_max'], i),
        ));
      }
    }

    final hourly = <HourlyForecast>[];
    final h = json['hourly'] as Map<String, dynamic>?;
    if (h != null) {
      final now = current.time;
      final startHour = DateTime(now.year, now.month, now.day, now.hour);
      final times = List<String>.from(h['time'] ?? const []);
      for (var i = 0; i < times.length && hourly.length < 24; i++) {
        final time = DateTime.parse(times[i]);
        if (time.isBefore(startHour)) continue;
        hourly.add(HourlyForecast(
          time: time,
          temperature: _doubleAt(h['temperature_2m'], i) ?? 0,
          weatherCode: _intAt(h['weather_code'], i) ?? 0,
          precipitationProbability: _intAt(h['precipitation_probability'], i),
        ));
      }
    }

    return WeatherData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? '',
      current: current,
      hourly: hourly,
      daily: daily,
    );
  }
}

class CurrentWeather {
  final DateTime time;
  final double temperature;
  final int humidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final bool isDay;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature_2m'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).round(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0,
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      isDay: (json['is_day'] ?? 1) == 1,
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int? precipitationProbability;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    this.precipitationProbability,
  });

  bool get isDay => time.hour >= 6 && time.hour < 18;
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final int? precipitationProbability;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double? uvIndexMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    this.precipitationProbability,
    this.sunrise,
    this.sunset,
    this.uvIndexMax,
  });
}

double? _doubleAt(dynamic list, int i) {
  if (list is! List || i >= list.length || list[i] == null) return null;
  return (list[i] as num).toDouble();
}

int? _intAt(dynamic list, int i) {
  if (list is! List || i >= list.length || list[i] == null) return null;
  return (list[i] as num).round();
}

DateTime? _dateAt(dynamic list, int i) {
  if (list is! List || i >= list.length || list[i] == null) return null;
  return DateTime.tryParse(list[i] as String);
}
