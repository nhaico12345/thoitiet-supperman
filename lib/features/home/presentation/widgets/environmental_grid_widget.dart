// Widget lưới hiển thị các chỉ số môi trường.
// Bao gồm: UV, độ ẩm, thời gian mặt trời mọc/lặn, áp suất.

import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';

class EnvironmentalGridWidget extends StatelessWidget {
  final WeatherEntity weather;

  const EnvironmentalGridWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildCard(
          context,
          title: 'Chỉ số UV',
          value: '${weather.uvIndex ?? "--"}',
          subtitle: (weather.uvIndex ?? 0) > 8 ? 'Cảnh báo: Cao!' : 'Thấp',
          color: _getUvColor(weather.uvIndex),
        ),
        _buildCard(
          context,
          title: 'Độ ẩm',
          value: '${weather.humidity ?? "--"}%',
          subtitle: 'Cảm giác như ${weather.feelsLike ?? "--"}°',
        ),
        _buildCard(
          context,
          title: 'Mặt trời',
          value: 'Mọc: ${_formatTime(weather.sunrise)}',
          subtitle: 'Lặn: ${_formatTime(weather.sunset)}',
        ),
        _buildCard(
          context,
          title: 'Áp suất',
          value: '${weather.pressure ?? "--"} hPa',
          subtitle: 'Bình thường',
        ),
      ],
    );
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return "--:--";
    final date = DateTime.tryParse(isoTime);
    if (date == null) return isoTime;
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color? _getUvColor(double? uv) {
    if (uv == null) return null;
    if (uv > 8) return Colors.purple.shade100;
    if (uv > 5) return Colors.orange.shade100;
    return Colors.green.shade100;
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
    Color? color,
  }) {
    return Card(
      color: color ?? Colors.white.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}
