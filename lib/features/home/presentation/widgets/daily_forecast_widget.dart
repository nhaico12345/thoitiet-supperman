// Widget hiển thị dự báo thời tiết 10 ngày.
// Hiển thị nhiệt độ cao/thấp, chỉ số UV và icon thời tiết theo ngày.

import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const DailyForecastWidget({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dự báo hàng ngày (10 ngày)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: forecasts.length,
          itemBuilder: (context, index) {
            final forecast = forecasts[index];
            final date = DateTime.tryParse(forecast.date);
            final dateStr = date != null
                ? "${date.day}/${date.month}"
                : forecast.date;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(
                  dateStr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Row(
                  children: [
                    Text(
                      _getWeatherEmoji(forecast.weatherCode),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text('Max UV: ${forecast.uvMax}'),
                  ],
                ),
                trailing: Text('${forecast.maxTemp}° / ${forecast.minTemp}°'),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getWeatherEmoji(int code) {
    // Icon 1: Sunny (Clear/Sunny)
    if (code == 0 || code == 1) return "🌤️";

    // Icon 2: Rain (Rain/Drizzle/Showers/Thunderstorm)
    if (code >= 51 && code <= 67) return "🌧️";
    if (code >= 80 && code <= 82) return "🌧️";
    if (code >= 95) return "⛈️";

    // Icon 3: Cloudy (Cloudy/Overcast/Fog)
    return "☁️";
  }
}
