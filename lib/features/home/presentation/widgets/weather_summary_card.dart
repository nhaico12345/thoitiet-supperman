// Thẻ hiển thị tóm tắt thời tiết từ AI với hiệu ứng đánh máy.

import 'package:flutter/material.dart';
import 'dart:async';

class WeatherSummaryCard extends StatefulWidget {
  final String summary;
  final bool isLoading;

  const WeatherSummaryCard({
    super.key,
    required this.summary,
    this.isLoading = false,
  });

  @override
  State<WeatherSummaryCard> createState() => _WeatherSummaryCardState();
}

class _WeatherSummaryCardState extends State<WeatherSummaryCard>
    with AutomaticKeepAliveClientMixin {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;
  String? _animatedSummary;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!widget.isLoading && widget.summary.isNotEmpty) {
      _startTypewriter();
    }
  }

  @override
  void didUpdateWidget(covariant WeatherSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.summary != oldWidget.summary && !widget.isLoading) {
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    _timer?.cancel();

    if (_animatedSummary == widget.summary) {
      setState(() {
        _displayedText = widget.summary;
        _currentIndex = widget.summary.length;
      });
      return;
    }

    _currentIndex = 0;
    _displayedText = '';
    _animatedSummary = widget.summary;

    if (widget.summary.isEmpty) return;

    final summaryChars = widget.summary.characters.toList();

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_currentIndex < summaryChars.length) {
        if (mounted) {
          setState(() {
            _displayedText += summaryChars[_currentIndex];
            _currentIndex++;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.isLoading) {
      return _buildGlassCard(
        child: Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Đang phân tích thời tiết...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.summary.isEmpty) return const SizedBox.shrink();

    return _buildGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _displayedText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
