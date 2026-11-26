import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/weather_condition.dart';
import '../../models/weather.dart';
import 'weather_icon.dart';

class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({
    super.key,
    required this.days,
    this.currentTemp,
  });

  final List<DailyForecast> days;
  final double? currentTemp;

  @override
  Widget build(BuildContext context) {
    final weekMin = days.map((d) => d.minTemp).reduce(math.min);
    final weekMax = days.map((d) => d.maxTemp).reduce(math.max);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'Prakiraan 7 Hari',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) const Divider(),
            _DayRow(
              day: days[i],
              isToday: i == 0,
              weekMin: weekMin,
              weekMax: weekMax,
              currentTemp: i == 0 ? currentTemp : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.isToday,
    required this.weekMin,
    required this.weekMax,
    this.currentTemp,
  });

  final DailyForecast day;
  final bool isToday;
  final double weekMin;
  final double weekMax;
  final double? currentTemp;

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCondition.fromCode(day.weatherCode);
    final rain = day.precipitationProbability ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              isToday ? 'Hari ini' : Fmt.shortDay(day.date),
              style: TextStyle(
                fontSize: 14,
                color: isToday ? AppColors.ink : AppColors.inkSecondary,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 78,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WeatherGlyph(kind: condition.kind, size: 28),
                const SizedBox(width: 6),
                SizedBox(
                  width: 34,
                  child: Text(
                    '$rain%',
                    style: const TextStyle(
                      color: AppColors.skyTop,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              Fmt.temp(day.minTemp),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.inkSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TempRangeBar(
              low: day.minTemp,
              high: day.maxTemp,
              weekMin: weekMin,
              weekMax: weekMax,
              currentTemp: currentTemp,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 34,
            child: Text(
              Fmt.temp(day.maxTemp),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TempRangeBar extends StatelessWidget {
  const _TempRangeBar({
    required this.low,
    required this.high,
    required this.weekMin,
    required this.weekMax,
    this.currentTemp,
  });

  final double low;
  final double high;
  final double weekMin;
  final double weekMax;
  final double? currentTemp;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = math.max(weekMax - weekMin, 1.0);
        final width = constraints.maxWidth;
        final left = ((low - weekMin) / span * width).clamp(0.0, width);
        final barWidth = math.max((high - low) / span * width, 10.0);
        final clampedLeft = math.min(left, math.max(0.0, width - barWidth));

        return Container(
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFE4E9F2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              Positioned(
                left: clampedLeft,
                width: math.min(barWidth, width),
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [AppColors.skyMid, AppColors.sunGold],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
