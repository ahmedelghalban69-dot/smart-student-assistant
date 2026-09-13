import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});
  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  static const _focusSecs = 25 * 60;
  static const _breakSecs = 5 * 60;

  int _remaining = _focusSecs;
  bool _running = false;
  bool _isBreak = false;
  Timer? _timer;
  int _sessionsCompleted = 0;

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining <= 0) {
          _completeSession();
        } else {
          setState(() => _remaining--);
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    setState(() => _running = false);

    if (!_isBreak) {
      _sessionsCompleted++;
      try {
        await Supabase.instance.client.from('study_sessions').insert({
          'user_id': Supabase.instance.client.auth.currentUser!.id,
          'duration_minutes': 25,
          'ended_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isBreak ? '✅ انتهت الراحة!' : '🎉 أنهيت جلسة 25 دقيقة!'),
      ));
    }

    setState(() {
      _isBreak = !_isBreak;
      _remaining = _isBreak ? _breakSecs : _focusSecs;
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remaining = _isBreak ? _breakSecs : _focusSecs;
    });
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final total = _isBreak ? _breakSecs : _focusSecs;
    final progress = 1 - (_remaining / total);

    return Scaffold(
      appBar: AppBar(title: const Text('⏱️ جلسة مذاكرة')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text(_isBreak ? '☕ وقت الراحة' : '📖 وقت التركيز',
                style: t.textTheme.titleLarge),
            const SizedBox(height: 30),
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: t.colorScheme.surfaceContainerHighest,
                  ),
                  Center(
                    child: Text(
                      _fmt(_remaining),
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('الجلسات المكتملة اليوم: $_sessionsCompleted',
                style: t.textTheme.bodyMedium),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: _reset,
                  iconSize: 32,
                  icon: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 20),
                IconButton.filled(
                  onPressed: _toggle,
                  iconSize: 48,
                  padding: const EdgeInsets.all(20),
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 20),
                IconButton.filledTonal(
                  onPressed: _completeSession,
                  iconSize: 32,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
