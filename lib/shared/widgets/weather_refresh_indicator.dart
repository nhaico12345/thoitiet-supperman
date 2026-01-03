// Widget kéo để làm mới với animation thời tiết tùy chỉnh.
// Hỗ trợ haptic feedback và hiệu ứng loading Lottie.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

// Custom pull-to-refresh indicator with weather animation
class WeatherRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final VoidCallback? onRefreshComplete;

  const WeatherRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.onRefreshComplete,
  });

  @override
  State<WeatherRefreshIndicator> createState() =>
      _WeatherRefreshIndicatorState();
}

class _WeatherRefreshIndicatorState extends State<WeatherRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isRefreshing = false;
  double _pullDistance = 0;
  static const double _triggerDistance = 100;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    _rotationController.repeat();

    // Haptic feedback when refresh triggered
    HapticFeedback.mediumImpact();

    try {
      await widget.onRefresh();
      widget.onRefreshComplete?.call();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
        _rotationController.stop();
        _rotationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (notification.metrics.pixels < 0 && !_isRefreshing) {
            setState(() {
              _pullDistance = -notification.metrics.pixels;
            });
          }
        }
        if (notification is ScrollEndNotification) {
          if (_pullDistance >= _triggerDistance && !_isRefreshing) {
            _handleRefresh();
          }
          setState(() => _pullDistance = 0);
        }
        return false;
      },
      child: Stack(
        children: [
          // Main content
          widget.child,

          // Pull indicator
          if (_pullDistance > 0 || _isRefreshing)
            Positioned(top: 0, left: 0, right: 0, child: _buildIndicator()),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    final progress = (_pullDistance / _triggerDistance).clamp(0.0, 1.0);
    final height = _isRefreshing ? 80.0 : _pullDistance.clamp(0.0, 100.0);

    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.withValues(alpha: 0.3), Colors.transparent],
        ),
      ),
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _isRefreshing
                ? _rotationController.value * 2 * 3.14159
                : progress * 3.14159,
            child: _buildWeatherIcon(progress),
          );
        },
      ),
    );
  }

  Widget _buildWeatherIcon(double progress) {
    final size = 40 + (progress * 20);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isRefreshing
          ? Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_bpq7q2ce.json', // Weather loading animation
              width: size * 0.7,
              height: size * 0.7,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.cloud_sync,
                  size: size * 0.5,
                  color: Colors.blue,
                );
              },
            )
          : Icon(
              Icons.cloud_download_outlined,
              size: size * 0.5,
              color: Colors.blue.withValues(alpha: progress),
            ),
    );
  }
}

// Simple wrapper using standard RefreshIndicator with enhancements
class EnhancedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final VoidCallback? onRefreshComplete;

  const EnhancedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.onRefreshComplete,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Haptic feedback
        HapticFeedback.mediumImpact();

        await onRefresh();

        // Call completion callback
        onRefreshComplete?.call();
      },
      color: Colors.white,
      backgroundColor: Colors.blue.shade600,
      strokeWidth: 3,
      displacement: 50,
      child: child,
    );
  }
}
