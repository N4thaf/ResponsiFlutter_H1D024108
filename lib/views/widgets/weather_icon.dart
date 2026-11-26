import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/weather_condition.dart';

class SaddleSheetClipper extends CustomClipper<Path> {
  const SaddleSheetClipper({this.dip = 16, this.shoulderRadius = 34});

  final double dip;
  final double shoulderRadius;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = shoulderRadius;

    final path = Path();
    path.moveTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.cubicTo(
      w * 0.28,
      0,
      w * 0.36,
      dip,
      w * 0.50,
      dip,
    );
    path.cubicTo(
      w * 0.64,
      dip,
      w * 0.72,
      0,
      w - r,
      0,
    );
    path.quadraticBezierTo(w, 0, w, r);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant SaddleSheetClipper oldClipper) =>
      oldClipper.dip != dip || oldClipper.shoulderRadius != shoulderRadius;
}

class TuscanyMenuIcon extends StatelessWidget {
  const TuscanyMenuIcon({super.key, this.color = Colors.white});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 14,
      child: CustomPaint(
        painter: _TuscanyMenuPainter(color),
      ),
    );
  }
}

class _TuscanyMenuPainter extends CustomPainter {
  const _TuscanyMenuPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.18, 3.5), Offset(size.width, 3.5), paint);
    canvas.drawLine(Offset(0, size.height - 3.5), Offset(size.width, size.height - 3.5), paint);
  }

  @override
  bool shouldRepaint(covariant _TuscanyMenuPainter oldDelegate) => oldDelegate.color != color;
}

class FadingSkyTemperature extends StatelessWidget {
  const FadingSkyTemperature({
    super.key,
    required this.temperature,
  });

  final double temperature;

  @override
  Widget build(BuildContext context) {
    final digits = '${temperature.round()}';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.96),
              Colors.white.withValues(alpha: 0.72),
              Colors.white.withValues(alpha: 0.35),
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: Text(
            digits,
            style: const TextStyle(
              fontSize: 102,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: -4.0,
              height: 0.95,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Positioned(
          right: -18,
          top: -4,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.92),
                width: 2.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WeatherGlyph extends StatelessWidget {
  const WeatherGlyph({
    super.key,
    required this.kind,
    this.size = 34,
  });

  final WeatherKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TuscanyWeatherIconPainter(kind),
      ),
    );
  }
}

class _TuscanyWeatherIconPainter extends CustomPainter {
  const _TuscanyWeatherIconPainter(this.kind);

  final WeatherKind kind;

  static const _gold = Color(0xFFFFBC2C);
  static const _goldHalo = Color(0xFFFFE59E);
  static const _outline = Color(0xFF262C3A);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    switch (kind) {
      case WeatherKind.clearDay:
      case WeatherKind.clearNight:
        _drawSunny(canvas, s);
      case WeatherKind.partlyCloudyDay:
      case WeatherKind.partlyCloudyNight:
      case WeatherKind.cloudy:
      case WeatherKind.overcast:
      case WeatherKind.fog:
        _drawSunAndOutlinedCloud(canvas, s);
      case WeatherKind.drizzle:
      case WeatherKind.rain:
      case WeatherKind.snow:
      case WeatherKind.thunderstorm:
        _drawOutlinedRainCloud(canvas, s);
    }
  }

  void _drawSunny(Canvas canvas, double s) {
    final center = Offset(s * 0.5, s * 0.5);
    final haloPaint = Paint()..color = _goldHalo.withValues(alpha: 0.45);
    canvas.drawCircle(center, s * 0.36, haloPaint);

    final dotPaint = Paint()..color = _gold.withValues(alpha: 0.55);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final pt = center + Offset(math.cos(a), math.sin(a)) * (s * 0.36);
      canvas.drawCircle(pt, s * 0.028, dotPaint);
    }

    canvas.drawCircle(center, s * 0.25, Paint()..color = _gold);
  }

  void _drawSunAndOutlinedCloud(Canvas canvas, double s) {
    final sunCenter = Offset(s * 0.34, s * 0.44);
    canvas.drawCircle(sunCenter, s * 0.22, Paint()..color = _gold);

    final cloudPath = _buildCloudPath(
      left: s * 0.22,
      bottom: s * 0.74,
      width: s * 0.66,
    );
    canvas.drawPath(cloudPath, Paint()..color = Colors.white);
    canvas.drawPath(
      cloudPath,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.65
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawOutlinedRainCloud(Canvas canvas, double s) {
    final cloudPath = _buildCloudPath(
      left: s * 0.16,
      bottom: s * 0.62,
      width: s * 0.68,
    );
    canvas.drawPath(cloudPath, Paint()..color = Colors.white);
    final strokePaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.65
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(cloudPath, strokePaint);

    final dropPaint = Paint()
      ..color = _outline
      ..strokeWidth = 1.45
      ..strokeCap = StrokeCap.round;

    final drops = [
      Offset(s * 0.33, s * 0.70),
      Offset(s * 0.48, s * 0.70),
      Offset(s * 0.63, s * 0.70),
      Offset(s * 0.40, s * 0.82),
      Offset(s * 0.55, s * 0.82),
    ];
    for (final pt in drops) {
      canvas.drawLine(pt, Offset(pt.dx - s * 0.03, pt.dy + s * 0.065), dropPaint);
    }
  }

  Path _buildCloudPath({
    required double left,
    required double bottom,
    required double width,
  }) {
    final h = width * 0.54;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTRB(left + width * 0.06, bottom - h * 0.56, left + width * 0.94, bottom),
      Radius.circular(h * 0.28),
    );
    final p = Path()..addRRect(rect);
    p.addOval(
      Rect.fromCircle(
        center: Offset(left + width * 0.34, bottom - h * 0.48),
        radius: width * 0.21,
      ),
    );
    p.addOval(
      Rect.fromCircle(
        center: Offset(left + width * 0.56, bottom - h * 0.58),
        radius: width * 0.25,
      ),
    );
    p.addOval(
      Rect.fromCircle(
        center: Offset(left + width * 0.76, bottom - h * 0.38),
        radius: width * 0.16,
      ),
    );

    var combined = Path()..addRRect(rect);
    combined = Path.combine(
      PathOperation.union,
      combined,
      Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(left + width * 0.34, bottom - h * 0.48),
            radius: width * 0.21,
          ),
        ),
    );
    combined = Path.combine(
      PathOperation.union,
      combined,
      Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(left + width * 0.56, bottom - h * 0.58),
            radius: width * 0.25,
          ),
        ),
    );
    combined = Path.combine(
      PathOperation.union,
      combined,
      Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(left + width * 0.76, bottom - h * 0.38),
            radius: width * 0.16,
          ),
        ),
    );
    return combined;
  }

  @override
  bool shouldRepaint(covariant _TuscanyWeatherIconPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
