// File: home_mobile_layout.dart
// Mô tả: Layout màn hình chính cho thiết bị di động (điện thoại).
// Hiển thị dạng danh sách dọc: thời tiết, OOTD, gợi ý, AQI, dự báo.

import 'package:flutter/material.dart';
import '../../../domain/entities/weather.dart';
import '../../../../settings/domain/entities/settings.dart';
import '../../widgets/current_weather_card.dart';
import '../../widgets/last_updated_banner.dart';
import '../../widgets/recommendation_widget.dart';
import '../../widgets/aqi_widget.dart';
import '../../widgets/hourly_forecast_widget.dart';
import '../../widgets/environmental_grid_widget.dart';
import '../../widgets/daily_forecast_widget.dart';
import '../../widgets/weather_summary_card.dart';
import '../../../domain/services/recommendation_service.dart';

class HomeMobileLayout extends StatelessWidget {
  final WeatherEntity weather;
  final SettingsEntity settings;
  final List<Recommendation> recommendations;
  final bool isAILoading;
  final String? weatherSummary;
  final String? ootdAdvice;
  final List<String>? smartWarnings;

  const HomeMobileLayout({
    super.key,
    required this.weather,
    required this.settings,
    this.recommendations = const [],
    this.isAILoading = false,
    this.weatherSummary,
    this.ootdAdvice,
    this.smartWarnings,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
      children: [
        LastUpdatedBanner(lastUpdated: weather.lastUpdated),

        // Smart Warnings
        if (smartWarnings != null && smartWarnings!.isNotEmpty) ...[
          for (var warning in smartWarnings!)
            Card(
              color: Colors.red.withValues(alpha: 0.1),
              child: ListTile(
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
                title: Text(
                  warning,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
        ],

        CurrentWeatherCard(weather: weather, settings: settings),

        // OOTD Card
        if (ootdAdvice != null) ...[
          Card(
            elevation: 2,
            color: Colors.purple.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checkroom, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        "Trang phục hôm nay (OOTD)",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ootdAdvice!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        if (weatherSummary != null || isAILoading) ...[
          WeatherSummaryCard(
            summary: weatherSummary ?? '',
            isLoading: isAILoading,
          ),
        ],
        const SizedBox(height: 20),
        RecommendationWidget(
          recommendations: recommendations,
          isLoading: isAILoading,
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.white.withValues(alpha: 0.9),
          child: AqiWidget(aqi: weather.aqi),
        ),
        const SizedBox(height: 20),
        if (weather.hourlyForecasts != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HourlyForecastWidget(forecasts: weather.hourlyForecasts!),
          ),
        const SizedBox(height: 20),
        EnvironmentalGridWidget(weather: weather),
        const SizedBox(height: 20),
        if (weather.dailyForecasts != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DailyForecastWidget(forecasts: weather.dailyForecasts!),
          ),
      ],
    );
  }
}
