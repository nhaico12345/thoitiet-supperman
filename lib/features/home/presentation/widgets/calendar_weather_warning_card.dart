// Widget hiển thị cảnh báo thời tiết cho sự kiện lịch.
// Hiển thị danh sách sự kiện ngoài trời có thể bị ảnh hưởng bởi thời tiết xấu.

import 'package:flutter/material.dart';

class CalendarEventWarning {
  final String eventTitle;
  final DateTime eventTime;
  final String warningMessage;
  final String weatherDescription;
  final int weatherCode;

  const CalendarEventWarning({
    required this.eventTitle,
    required this.eventTime,
    required this.warningMessage,
    required this.weatherDescription,
    required this.weatherCode,
  });

  String get formattedTime {
    final hour = eventTime.hour.toString().padLeft(2, '0');
    final minute = eventTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class CalendarWeatherWarningCard extends StatelessWidget {
  final List<CalendarEventWarning> warnings;
  final VoidCallback? onDismiss;

  const CalendarWeatherWarningCard({
    super.key,
    required this.warnings,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade700.withValues(alpha: 0.9),
            Colors.deepOrange.shade600.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '⚠️ Cảnh báo sự kiện',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${warnings.length} sự kiện có thể bị ảnh hưởng',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onDismiss != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: onDismiss,
                        splashRadius: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),
                // Event list
                ...warnings.take(3).map((warning) => _buildEventItem(warning)),
                if (warnings.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'và ${warnings.length - 3} sự kiện khác...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventItem(CalendarEventWarning warning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              warning.formattedTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Event details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning.eventTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  warning.warningMessage,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Weather icon
          Text(
            _getWeatherEmoji(warning.weatherCode),
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  String _getWeatherEmoji(int code) {
    if (code >= 95) return '⛈️';
    if (code >= 80) return '🌧️';
    if (code >= 61) return '🌧️';
    if (code >= 51) return '🌦️';
    if (code >= 45) return '🌫️';
    return '⚠️';
  }
}
