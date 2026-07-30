import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class BreathingTimerWidget extends StatefulWidget {
  final Function(int count, bool isFastBreathing) onTimerComplete;

  const BreathingTimerWidget({super.key, required this.onTimerComplete});

  @override
  State<BreathingTimerWidget> createState() => _BreathingTimerWidgetState();
}

class _BreathingTimerWidgetState extends State<BreathingTimerWidget> {
  int _secondsRemaining = 60;
  int _breathCount = 0;
  bool _isRunning = false;
  Timer? _timer;

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _breathCount = 0;
      _isRunning = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _isRunning = false;
        });
        final isFast = _breathCount > 60;
        widget.onTimerComplete(_breathCount, isFast);
      }
    });
  }

  void _recordBreath() {
    if (_isRunning) {
      setState(() {
        _breathCount++;
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _breathCount = 0;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFast = _breathCount > 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFast && !_isRunning ? AppTheme.urgentRed : AppTheme.cardBorder,
          width: isFast && !_isRunning ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppTheme.primaryNavy, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '60-Second Breathing Rate Timer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              if (_isRunning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_secondsRemaining}s',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '$_breathCount',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isFast ? AppTheme.urgentRed : AppTheme.primaryNavy,
                    ),
                  ),
                  const Text('Breaths Counted', style: TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                ],
              ),
              Column(
                children: [
                  Text(
                    _isRunning ? '${60 - _secondsRemaining}s' : '60s',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMedium,
                    ),
                  ),
                  const Text('Elapsed Time', style: TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isRunning) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _recordBreath,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.touch_app, size: 24),
                label: const Text('TAP ON EACH BREATH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _resetTimer,
              child: const Text('Cancel & Reset', style: TextStyle(color: AppTheme.textMedium)),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_breathCount > 0 ? 'Retake Count' : 'Start 60s Count'),
                  ),
                ),
              ],
            ),
          ],
          if (!_isRunning && _breathCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFast ? AppTheme.urgentRedLight : AppTheme.routineGreenLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isFast ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: isFast ? AppTheme.urgentRed : AppTheme.routineGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isFast
                          ? 'FAST BREATHING DETECTED ($_breathCount/min > 60/min limit for infants <2m)'
                          : 'Normal breathing rate ($_breathCount/min <= 60/min)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isFast ? AppTheme.urgentRed : AppTheme.routineGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
