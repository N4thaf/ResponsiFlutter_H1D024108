import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'services/storage_service.dart';
import 'services/weather_api_service.dart';
import 'viewmodels/favorite_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  final api = WeatherApiService();
  final storage = StorageService();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider.value(value: storage),
        ChangeNotifierProvider(create: (_) => FavoriteViewModel(storage)..load()),
        ChangeNotifierProvider(create: (_) => WeatherViewModel(api, storage)..init()),
      ],
      child: const CuacaApp(),
    ),
  );
}

class CuacaApp extends StatelessWidget {
  const CuacaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaca',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
