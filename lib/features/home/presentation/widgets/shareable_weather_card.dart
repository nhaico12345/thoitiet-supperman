// Thẻ thời tiết đẹp kích thước Instagram Story (1080x1920).
// Dùng để chụp ảnh và chia sẻ lên mạng xã hội với gradient theo thời tiết.

import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';

class ShareableWeatherCard extends StatelessWidget {
  final WeatherEntity weather;
  final String? ootdAdvice;
  final String appName;

  const ShareableWeatherCard({
    super.key,
    required this.weather,
    this.ootdAdvice,
    this.appName = 'Siêu thời tiết',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: _getGradient(weather.weatherCode ?? 0),
      ),
      child: Stack(
        children: [
          _buildBackgroundPattern(),
          Padding(
            padding: const EdgeInsets.all(80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 1),

                Text(
                  _getWeatherEmoji(weather.weatherCode ?? 0),
                  style: const TextStyle(fontSize: 200),
                ),

                const SizedBox(height: 40),

                Text(
                  '${weather.temperature?.toStringAsFixed(0) ?? '--'}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 220,
                    fontWeight: FontWeight.w200,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _getWeatherDescription(weather.weatherCode ?? 0),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 60),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      weather.locationName ?? 'Vị trí hiện tại',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  _formatDateTime(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const Spacer(flex: 1),

                _buildWeatherDetails(),

                const SizedBox(height: 60),
                if (ootdAdvice != null && ootdAdvice!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('👕', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Text(
                              'Gợi ý hôm nay',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ootdAdvice!,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(flex: 1),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            appName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pattern.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDetailItem('💧', '${weather.humidity ?? '--'}%', 'Độ ẩm'),
          _buildDetailDivider(),
          _buildDetailItem(
            '💨',
            '${weather.windSpeed?.toStringAsFixed(0) ?? '--'} km/h',
            'Gió',
          ),
          _buildDetailDivider(),
          _buildDetailItem(
            '☀️',
            weather.uvIndex?.toStringAsFixed(1) ?? '--',
            'UV',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailDivider() {
    return Container(
      width: 1,
      height: 80,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  LinearGradient _getGradient(int weatherCode) {
    // Thunderstorm
    if (weatherCode >= 95) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
      );
    }
    // Rain/Showers
    if (weatherCode >= 51 && weatherCode <= 82) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2c3e50), Color(0xFF3498db), Color(0xFF1abc9c)],
      );
    }
    // Fog
    if (weatherCode >= 45 && weatherCode <= 48) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF636e72), Color(0xFFb2bec3), Color(0xFFdfe6e9)],
      );
    }
    // Cloudy
    if (weatherCode >= 2 && weatherCode <= 3) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF74b9ff), Color(0xFF0984e3), Color(0xFF6c5ce7)],
      );
    }
    // Clear/Sunny (default)
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF4facfe), Color(0xFF00f2fe), Color(0xFF43e97b)],
    );
  }

  String _getWeatherEmoji(int code) {
    if (code >= 95) return '⛈️';
    if (code >= 80) return '🌧️';
    if (code >= 61) return '🌧️';
    if (code >= 51) return '🌦️';
    if (code >= 45) return '🌫️';
    if (code >= 3) return '☁️';
    if (code >= 1) return '⛅';
    return '☀️';
  }

  String _getWeatherDescription(int code) {
    if (code >= 95) return 'GIÔNG BÃO';
    if (code >= 80) return 'MƯA RÀO';
    if (code >= 61) return 'MƯA';
    if (code >= 51) return 'MƯA PHÙN';
    if (code >= 45) return 'SƯƠNG MÙ';
    if (code >= 3) return 'NHIỀU MÂY';
    if (code >= 1) return 'CÓ MÂY';
    return 'TRỜI QUANG';
  }

  String _formatDateTime() {
    final now = DateTime.now();
    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final months = [
      '',
      'Th1',
      'Th2',
      'Th3',
      'Th4',
      'Th5',
      'Th6',
      'Th7',
      'Th8',
      'Th9',
      'Th10',
      'Th11',
      'Th12',
    ];

    return '${weekdays[now.weekday % 7]}, ${now.day} ${months[now.month]} ${now.year} • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
