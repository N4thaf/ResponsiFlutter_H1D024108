import 'package:intl/intl.dart';

class Fmt {
  Fmt._();

  static String temp(double value) => '${value.round()}°';

  static String tempNumber(double value) => '${value.round()}';

  static String hour(DateTime time) => DateFormat.Hm('id_ID').format(time);

  static String shortDay(DateTime date) => DateFormat('EEE', 'id_ID').format(date);

  static String fullDate(DateTime date) => DateFormat('EEEE, d MMMM', 'id_ID').format(date);

  static String uvLevel(double uv) {
    if (uv < 3) return 'Rendah';
    if (uv < 6) return 'Sedang';
    if (uv < 8) return 'Tinggi';
    if (uv < 11) return 'Sangat tinggi';
    return 'Ekstrem';
  }

  static String humidityLevel(int humidity) {
    if (humidity < 40) return 'Udara kering';
    if (humidity <= 70) return 'Nyaman';
    return 'Udara lembap';
  }

  static String windLevel(double kmh) {
    if (kmh < 6) return 'Tenang';
    if (kmh < 20) return 'Sepoi-sepoi';
    if (kmh < 39) return 'Cukup kencang';
    return 'Kencang';
  }

  static String flag(String? countryCode) {
    if (countryCode == null || countryCode.length != 2) return '';
    const base = 0x1F1E6;
    final code = countryCode.toUpperCase();
    return String.fromCharCodes([
      base + code.codeUnitAt(0) - 65,
      base + code.codeUnitAt(1) - 65,
    ]);
  }
}
