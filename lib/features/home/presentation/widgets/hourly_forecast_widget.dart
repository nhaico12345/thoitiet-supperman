// Widget hiển thị biểu đồ nhiệt độ 24 giờ dạng đường cong.

import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../../../core/utils/weather_constants.dart';
import '../../../../core/utils/weather_icon_helper.dart';

class HourlyForecastWidget extends StatefulWidget {
  final List<HourlyForecast> forecasts;

  const HourlyForecastWidget({super.key, required this.forecasts});

  @override
  State<HourlyForecastWidget> createState() => _HourlyForecastWidgetState();
}

class _HourlyForecastWidgetState extends State<HourlyForecastWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.forecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1f38), Color(0xFF0d1127)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Dự báo 24h',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Chart area
            SizedBox(
              height: 220,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: widget.forecasts.length * 70.0,
                  child: CustomPaint(
                    painter: _TemperatureChartPainter(
                      forecasts: widget.forecasts,
                    ),
                    child: _buildForecastItems(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItems() {
    final now = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widget.forecasts.asMap().entries.map((entry) {
        final index = entry.key;
        final forecast = entry.value;
        final time = DateTime.tryParse(forecast.time);
        final isNow = index == 0;

        return SizedBox(
          width: 70,
          child: Column(
            children: [
              const SizedBox(height: 5),
              // Nhiệt độ
              Text(
                '${forecast.temperature.toInt()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Icon thời tiết - dùng helper
              Text(
                WeatherIconHelper.getEmoji(forecast.weatherCode),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              // Cấp gió - dùng BeaufortScale
              Text(
                'Cấp ${BeaufortScale.getLevel(forecast.windSpeed)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              // Thời gian
              Text(
                _formatTime(time, isNow, now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(DateTime? time, bool isNow, DateTime now) {
    if (isNow) return 'Bây giờ';
    if (time == null) return '--:--';

    // Chỉ hiển thị ngày/tháng khi là 0:00 (nửa đêm) - đánh dấu sang ngày mới
    if (time.hour == 0) {
      return '${time.day}/${time.month}';
    }

    // Các giờ khác đều hiển thị số giờ bình thường
    return '${time.hour.toString().padLeft(2, '0')}:00';
  }
}

class _TemperatureChartPainter extends CustomPainter {
  final List<HourlyForecast> forecasts;

  _TemperatureChartPainter({required this.forecasts});

  @override
  void paint(Canvas canvas, Size size) {
    if (forecasts.isEmpty) return;

    // Tính min/max nhiệt độ
    double minTemp = forecasts
        .map((e) => e.temperature)
        .reduce((a, b) => a < b ? a : b);
    double maxTemp = forecasts
        .map((e) => e.temperature)
        .reduce((a, b) => a > b ? a : b);
    double tempRange = maxTemp - minTemp;
    if (tempRange == 0) tempRange = 1; // Tránh chia 0

    // Vùng vẽ đường (để lại khoảng cho text phía trên và icon phía dưới)
    const double topPadding = 35;
    const double bottomPadding = 100;
    final double chartHeight = size.height - topPadding - bottomPadding;

    // Tạo các điểm
    final List<Offset> points = [];
    final double itemWidth = size.width / forecasts.length;

    for (int i = 0; i < forecasts.length; i++) {
      final double x = itemWidth * i + itemWidth / 2;
      final double normalizedTemp =
          (forecasts[i].temperature - minTemp) / tempRange;
      final double y = topPadding + chartHeight * (1 - normalizedTemp);
      points.add(Offset(x, y));
    }

    // Vẽ đường cong màu vàng-xanh lá
    final linePaint = Paint()
      ..color = const Color(0xFFc8e14e)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlX = (p0.dx + p1.dx) / 2;
        path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }
    }

    canvas.drawPath(path, linePaint);

    // Vẽ chấm tròn trắng tại điểm hiện tại (điểm đầu tiên)
    if (points.isNotEmpty) {
      final currentDotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points[0], 6, currentDotPaint);

      // Viền xanh nhạt cho chấm
      final borderPaint = Paint()
        ..color = const Color(0xFFc8e14e).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(points[0], 8, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TemperatureChartPainter oldDelegate) {
    // Chỉ vẽ lại khi dữ liệu thay đổi (so sánh độ dài và nhiệt độ đầu tiên)
    if (forecasts.length != oldDelegate.forecasts.length) return true;
    if (forecasts.isEmpty) return false;
    return forecasts.first.temperature !=
        oldDelegate.forecasts.first.temperature;
  }
}
