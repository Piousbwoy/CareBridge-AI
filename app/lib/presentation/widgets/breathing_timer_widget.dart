import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class BreathingTimerWidget extends StatefulWidget {
  final int initialRate;
  final ValueChanged<int>? onRateChanged;
  final Function(int count, bool isFastBreathing)? onTimerComplete;

  const BreathingTimerWidget({
    super.key,
    this.initialRate = 40,
    this.onRateChanged,
    this.onTimerComplete,
  });

  @override
  State<BreathingTimerWidget> createState() => _BreathingTimerWidgetState();
}

class _BreathingTimerWidgetState extends State<BreathingTimerWidget> {
  int _secondsRemaining = 60;
  late int _breathCount;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _breathCount = widget.initialRate;
  }

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
        final isFast = _breathCount >= 60;
        if (widget.onTimerComplete != null) {
          widget.onTimerComplete!(_breathCount, isFast);
        }
        if (widget.onRateChanged != null) {
          widget.onRateChanged!(_breathCount);
        }
      }
    });
  }

  void _recordBreath() {
    if (_isRunning) {
      setState(() {
        _breathCount++;
      });
      if (widget.onRateChanged != null) {
        widget.onRateChanged!(_breathCount);
      }
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _breathCount = widget.initialRate;
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
    final bool isFast = _breathCount >= 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('60-Second Breathing Counter', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFast ? AppTheme.urgentRed : AppTheme.routineGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isFast ? 'FAST (≥ 60/min)' : 'NORMAL (< 60/min)',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('$_secondsRemaining s', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    Text('Timer Remaining', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                  ],
                ),
                Column(
                  children: [
                    Text('$_breathCount', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: isFast ? AppTheme.urgentRed : AppTheme.accentTeal)),
                    Text('Breaths Counted', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMedium)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? _recordBreath : _startTimer,
                    icon: Icon(_isRunning ? Icons.touch_app_rounded : Icons.play_arrow_rounded, color: Colors.white),
                    label: Text(_isRunning ? 'TAP FOR BREATH (+1)' : 'START TIMER', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning ? AppTheme.accentTeal : AppTheme.primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (_isRunning || _secondsRemaining < 60) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppTheme.textMedium),
                    onPressed: _resetTimer,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
