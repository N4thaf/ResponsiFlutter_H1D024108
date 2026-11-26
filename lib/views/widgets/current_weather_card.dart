import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/weather_condition.dart';
import '../../models/location.dart';
import '../../models/weather.dart';
import 'weather_icon.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.weather,
    required this.location,
    required this.favorites,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenSearch,
    required this.onSelectFavorite,
  });

  final WeatherData weather;
  final Location? location;
  final List<Location> favorites;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenSearch;
  final ValueChanged<Location> onSelectFavorite;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final condition = WeatherCondition.fromCode(current.weatherCode, isDay: current.isDay);
    final topPad = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 510 + topPad,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/tuscany_landscape.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
          Positioned(
            top: topPad + 12,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.location_solid,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location?.name ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Favorit',
                      child: GestureDetector(
                        onTap: onToggleFavorite,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Icon(
                            isFavorite ? CupertinoIcons.star_fill : CupertinoIcons.star,
                            size: 20,
                            color: isFavorite ? AppColors.sunGold : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Cari kota',
                      child: GestureDetector(
                        onTap: onOpenSearch,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: TuscanyMenuIcon(),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 21, top: 2),
                  child: Text(
                    '${Fmt.fullDate(DateTime.now())}  •  ${Fmt.hour(current.time)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (favorites.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favorites.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final item = favorites[i];
                        final selected = item == location;
                        return GestureDetector(
                          onTap: () => onSelectFavorite(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                color: selected ? AppColors.skyTop : Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadingSkyTemperature(temperature: current.temperature),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          condition.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
