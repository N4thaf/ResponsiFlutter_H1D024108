import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const sunGold = Color(0xFFFFBC2C);
  static const sunPeach = Color(0xFFF5A382);
  static const skyTop = Color(0xFF68A4F4);
  static const skyMid = Color(0xFF9CCCF8);
  static const skyHorizon = Color(0xFFE4F2FA);

  static const ink = Color(0xFF222836);
  static const inkSecondary = Color(0xFF8F97A8);
  static const inkTertiary = Color(0xFFB4BCCB);

  static const sheetWhite = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF6F8FC);
  static const borderSoft = Color(0xFFECEFF6);

  static const orange = sunGold;
  static const orangeDark = Color(0xFFE59A0C);
  static const orangeWarm = sunGold;
  static const blue = skyTop;
  static const blueLight = skyMid;
  static const blueAccent = skyTop;
  static const green = skyTop;
  static const orangeSoft = sunPeach;

  static const background = skyTop;
  static const card = surfaceSoft;
  static const cardBorder = borderSoft;
  static const field = surfaceSoft;
  static const divider = borderSoft;

  static const textPrimary = ink;
  static const textSecondary = inkSecondary;
  static const textTertiary = inkTertiary;
}

class AppTheme {
  AppTheme._();

  static const cardRadius = 20.0;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.skyTop,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.skyTop,
      onPrimary: Colors.white,
      secondary: AppColors.sunGold,
      surface: AppColors.sheetWhite,
      onSurface: AppColors.ink,
    );

    final textTheme = _textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.sheetWhite,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.black.withValues(alpha: 0.03),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceSoft,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.sunGold, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSoft,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.skyTop,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.skyTop,
          textStyle: textTheme.labelMedium,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sunGold,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static const _tabular = [FontFeature.tabularFigures()];

  static const _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 96,
      fontWeight: FontWeight.w400,
      letterSpacing: -3.5,
      height: 1.0,
      fontFeatures: _tabular,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      fontFeatures: _tabular,
    ),
    headlineMedium: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      fontFeatures: _tabular,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      fontFeatures: _tabular,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      fontFeatures: _tabular,
    ),
    bodyMedium: TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w400,
      fontFeatures: _tabular,
    ),
    bodySmall: TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w500,
      fontFeatures: _tabular,
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFeatures: _tabular,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontFeatures: _tabular,
    ),
    labelSmall: TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      fontFeatures: _tabular,
    ),
  );
}
