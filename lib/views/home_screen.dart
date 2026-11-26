import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/location.dart';
import '../models/weather.dart';
import '../services/storage_service.dart';
import '../services/weather_api_service.dart';
import '../viewmodels/favorite_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/view_state.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/daily_forecast_card.dart';
import 'widgets/hourly_forecast_card.dart';
import 'widgets/info_tile.dart';
import 'widgets/state_message.dart';
import 'widgets/weather_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openSearch(BuildContext context) async {
    final selected = await Navigator.of(context).push<Location>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (ctx) => SearchViewModel(
            ctx.read<WeatherApiService>(),
            ctx.read<StorageService>(),
          )..loadHistory(),
          child: const SearchScreen(),
        ),
      ),
    );
    if (selected != null && context.mounted) {
      context.read<WeatherViewModel>().selectLocation(selected);
    }
  }

  Future<void> _toggleFavorite(BuildContext context, Location location) async {
    final added = await context.read<FavoriteViewModel>().toggle(location);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(added
            ? '${location.name} disimpan ke favorit'
            : '${location.name} dihapus dari favorit'),
        duration: const Duration(seconds: 2),
      ));
  }

  Future<void> _onRefresh(BuildContext context) async {
    final error = await context.read<WeatherViewModel>().refresh();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final favorites = context.watch<FavoriteViewModel>();

    return Scaffold(
      backgroundColor: AppColors.sheetWhite,
      body: RefreshIndicator.adaptive(
        onRefresh: () => _onRefresh(context),
        child: _buildBody(context, vm, favorites),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherViewModel vm,
    FavoriteViewModel favorites,
  ) {
    switch (vm.state) {
      case ViewState.initial:
      case ViewState.loading:
        return const LoadingView(message: 'Memuat data cuaca...');
      case ViewState.error:
        return StateMessage(
          icon: CupertinoIcons.wifi_exclamationmark,
          title: 'Gagal memuat cuaca',
          message: vm.errorMessage ?? 'Terjadi kesalahan.',
          actionLabel: 'Coba lagi',
          onAction: vm.fetchWeather,
        );
      case ViewState.empty:
        return StateMessage(
          icon: CupertinoIcons.cloud,
          title: 'Data belum tersedia',
          message: 'Open-Meteo belum memiliki data prakiraan untuk lokasi ini.',
          actionLabel: 'Muat ulang',
          onAction: vm.fetchWeather,
        );
      case ViewState.success:
        return _buildWeather(context, vm.weather!, vm.location, favorites);
    }
  }

  Widget _buildWeather(
    BuildContext context,
    WeatherData weather,
    Location? location,
    FavoriteViewModel favorites,
  ) {
    final today = weather.today;
    final current = weather.current;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              CurrentWeatherCard(
                weather: weather,
                location: location,
                favorites: favorites.favorites,
                isFavorite: location != null && favorites.isFavorite(location),
                onToggleFavorite: location == null
                    ? () {}
                    : () => _toggleFavorite(context, location),
                onOpenSearch: () => _openSearch(context),
                onSelectFavorite: (loc) =>
                    context.read<WeatherViewModel>().selectLocation(loc),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 450 + MediaQuery.paddingOf(context).top,
                ),
                child: ClipPath(
                  clipper: const SaddleSheetClipper(dip: 16, shoulderRadius: 34),
                  child: Container(
                    color: AppColors.sheetWhite,
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 28),
                    child: Column(
                      children: [
                        if (weather.hourly.isNotEmpty)
                          HourlyForecastCard(
                            hours: weather.hourly,
                            current: weather.current,
                          ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _SummaryStrip(
                            apparentTemp: Fmt.temp(current.apparentTemperature),
                            maxTemp: today != null ? Fmt.temp(today.maxTemp) : '-',
                            minTemp: today != null ? Fmt.temp(today.minTemp) : '-',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.72,
                            children: _detailTiles(weather),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DailyForecastCard(
                            days: weather.daily,
                            currentTemp: weather.current.temperature,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sumber data: Open-Meteo API',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _detailTiles(WeatherData weather) {
    final current = weather.current;
    final today = weather.today;
    final uv = today?.uvIndexMax;
    final rainChance = today?.precipitationProbability ?? 0;

    return [
      InfoTile(
        label: 'Kelembapan',
        value: '${current.humidity}%',
        caption: Fmt.humidityLevel(current.humidity),
      ),
      InfoTile(
        label: 'Angin',
        value: '${current.windSpeed.round()} km/j',
        caption: Fmt.windLevel(current.windSpeed),
        isWarmAccent: true,
      ),
      InfoTile(
        label: 'Peluang Hujan',
        value: '$rainChance%',
        caption: 'Maksimum hari ini',
      ),
      InfoTile(
        label: 'Curah Hujan',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
        caption: 'Presipitasi saat ini',
      ),
      InfoTile(
        label: 'Indeks UV',
        value: uv == null ? '-' : uv.round().toString(),
        caption: uv == null ? '-' : Fmt.uvLevel(uv),
        isWarmAccent: true,
      ),
      InfoTile(
        label: 'Matahari Terbit',
        value: today?.sunrise == null ? '-' : Fmt.hour(today!.sunrise!),
        caption: today?.sunset == null ? '-' : 'Terbenam ${Fmt.hour(today!.sunset!)}',
        isWarmAccent: true,
      ),
    ];
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.apparentTemp,
    required this.maxTemp,
    required this.minTemp,
  });

  final String apparentTemp;
  final String maxTemp;
  final String minTemp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StripItem(label: 'Terasa Seperti', value: apparentTemp),
            ),
            Container(width: 1, color: AppColors.borderSoft),
            Expanded(
              child: _StripItem(label: 'Suhu Maks', value: maxTemp),
            ),
            Container(width: 1, color: AppColors.borderSoft),
            Expanded(
              child: _StripItem(label: 'Suhu Min', value: minTemp),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripItem extends StatelessWidget {
  const _StripItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.inkSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
