import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/weather_condition.dart';
import '../../models/weather.dart';
import 'weather_icon.dart';

class HourlyForecastCard extends StatelessWidget {
  const HourlyForecastCard({
    super.key,
    required this.hours,
    this.current,
  });

  final List<HourlyForecast> hours;
  final CurrentWeather? current;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 22,
          height: 2.5,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE0EA),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Cuaca Hari Ini',
          textAlign: TextAlign.center,
          style: text.titleLarge?.copyWith(
            color: AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 102,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: hours.length,
            separatorBuilder: (_, _) => const SizedBox(width: 18),
            itemBuilder: (context, i) => _HourItem(
              hour: hours[i],
              isNow: i == 0,
              currentOverride: i == 0 ? current : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _HourItem extends StatelessWidget {
  const _HourItem({
    required this.hour,
    required this.isNow,
    this.currentOverride,
  });

  final HourlyForecast hour;
  final bool isNow;
  final CurrentWeather? currentOverride;

  @override
  Widget build(BuildContext context) {
    final code = currentOverride?.weatherCode ?? hour.weatherCode;
    final isDay = currentOverride?.isDay ?? hour.isDay;
    final temp = currentOverride?.temperature ?? hour.temperature;
    final condition = WeatherCondition.fromCode(code, isDay: isDay);

    return SizedBox(
      width: 68,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WeatherGlyph(kind: condition.kind, size: 36),
          Text(
            isNow ? 'KINI' : Fmt.hour(hour.time),
            maxLines: 1,
            style: TextStyle(
              fontSize: 10.5,
              color: isNow ? AppColors.skyTop : AppColors.inkSecondary,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${temp.round()}',
                style: const TextStyle(
                  fontSize: 22,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Text(
                '°',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.inkSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
