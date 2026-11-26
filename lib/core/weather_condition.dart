import 'package:flutter/cupertino.dart';

import 'theme.dart';

enum WeatherKind {
  clearDay,
  clearNight,
  partlyCloudyDay,
  partlyCloudyNight,
  cloudy,
  overcast,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
}

class WeatherCondition {
  final String label;
  final WeatherKind kind;
  final IconData symbol;
  final Color accentColor;

  const WeatherCondition(this.label, this.kind, this.symbol, this.accentColor);

  factory WeatherCondition.fromCode(int code, {bool isDay = true}) {
    return switch (code) {
      0 => isDay
          ? const WeatherCondition('Cerah', WeatherKind.clearDay, CupertinoIcons.sun_max_fill, AppColors.orange)
          : const WeatherCondition('Cerah', WeatherKind.clearNight, CupertinoIcons.moon_stars_fill, AppColors.blue)
      ,
      1 => isDay
          ? const WeatherCondition('Cerah Berawan', WeatherKind.partlyCloudyDay, CupertinoIcons.cloud_sun_fill, AppColors.orange)
          : const WeatherCondition('Cerah Berawan', WeatherKind.partlyCloudyNight, CupertinoIcons.cloud_moon_fill, AppColors.blue),
      2 => const WeatherCondition('Berawan', WeatherKind.cloudy, CupertinoIcons.cloud_sun_fill, AppColors.orange),
      3 => const WeatherCondition('Mendung', WeatherKind.overcast, CupertinoIcons.cloud_fill, AppColors.blue),
      45 || 48 => const WeatherCondition('Berkabut', WeatherKind.fog, CupertinoIcons.cloud_fog_fill, AppColors.blue),
      51 || 53 || 55 || 56 || 57 => const WeatherCondition('Gerimis', WeatherKind.drizzle, CupertinoIcons.cloud_drizzle_fill, AppColors.blue),
      61 => const WeatherCondition('Hujan Ringan', WeatherKind.rain, CupertinoIcons.cloud_rain_fill, AppColors.blue),
      63 => const WeatherCondition('Hujan Sedang', WeatherKind.rain, CupertinoIcons.cloud_rain_fill, AppColors.blue),
      65 || 66 || 67 => const WeatherCondition('Hujan Lebat', WeatherKind.rain, CupertinoIcons.cloud_heavyrain_fill, AppColors.blue),
      71 || 73 || 75 || 77 || 85 || 86 => const WeatherCondition('Salju', WeatherKind.snow, CupertinoIcons.snow, AppColors.blue),
      80 => const WeatherCondition('Hujan Lokal', WeatherKind.drizzle, CupertinoIcons.cloud_drizzle_fill, AppColors.blue),
      81 || 82 => const WeatherCondition('Hujan Deras', WeatherKind.rain, CupertinoIcons.cloud_heavyrain_fill, AppColors.blue),
      95 || 96 || 99 => const WeatherCondition('Badai Petir', WeatherKind.thunderstorm, CupertinoIcons.cloud_bolt_rain_fill, AppColors.orange),
      _ => const WeatherCondition('Berawan', WeatherKind.cloudy, CupertinoIcons.cloud_fill, AppColors.blue),
    };
  }
}
