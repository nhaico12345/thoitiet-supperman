// Widget nền động thay đổi theo thời tiết (mưa, tuyết, nắng).

import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';

class WeatherBackgroundWidget extends StatelessWidget {
  final int? weatherCode;
  final bool isDay;
  final Widget child;

  const WeatherBackgroundWidget({
    super.key,
    required this.weatherCode,
    this.isDay = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final weatherType = _getWeatherType(weatherCode);

    return Stack(
      children: [
        RepaintBoundary(
          child: WeatherBg(
            weatherType: weatherType,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),

        // 3. Content
        SafeArea(child: child),
      ],
    );
  }

  WeatherType _getWeatherType(int? code) {
    if (code == null) return WeatherType.sunny;

    // https://open-meteo.com/en/docs

    if (code >= 95) return WeatherType.thunder;

    if (code >= 51 && code <= 67) {
      if (code >= 66) return WeatherType.heavyRainy;
      return WeatherType.middleRainy;
    }
    if (code >= 80 && code <= 82) return WeatherType.heavyRainy;

    // Snow
    if (code >= 71 && code <= 77) return WeatherType.heavySnow;
    if (code >= 85 && code <= 86) return WeatherType.heavySnow;

    // Fog
    if (code >= 45 && code <= 48) return WeatherType.foggy;

    // Cloudy
    if (code == 2 || code == 3) return WeatherType.cloudy;
    if (code == 1) return isDay ? WeatherType.cloudy : WeatherType.cloudyNight;

    // Clear / Sunny
    if (code == 0) return isDay ? WeatherType.sunny : WeatherType.sunnyNight;

    return WeatherType.sunny;
  }
}
