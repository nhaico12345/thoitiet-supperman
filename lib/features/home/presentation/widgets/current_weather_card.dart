// Widget hiển thị nhiệt độ và gió hiện tại.
// Tự động chuyển đổi đơn vị theo cài đặt người dùng (°C/°F, km/h/mph).

import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../../../core/utils/unit_converter.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherEntity weather;
  final SettingsEntity settings;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final temp = weather.temperature != null
        ? UnitConverter.convertTemp(weather.temperature!, settings.tempUnit)
        : null;
    final wind = weather.windSpeed != null
        ? UnitConverter.convertSpeed(weather.windSpeed!, settings.speedUnit)
        : null;
    final tempUnitStr = settings.tempUnit == TempUnit.celsius ? '°C' : '°F';
    final windUnitStr = settings.speedUnit == SpeedUnit.kmh ? 'km/h' : 'mph';

    return Card(
      color: Colors.white.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Nhiệt độ',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              '${temp?.toStringAsFixed(1) ?? "--"}$tempUnitStr',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: Colors.black87),
            ),
            Text(
              'Gió: ${wind?.toStringAsFixed(1)} $windUnitStr',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
