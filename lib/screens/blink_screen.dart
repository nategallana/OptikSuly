import 'dart:async';

import 'package:flutter/material.dart';
import 'package:optik_suly/models/assessment.dart';
import 'package:optik_suly/screens/tbut_screen.dart';
import 'package:optik_suly/theme/app_theme.dart';
import 'package:optik_suly/widgets/assessment_widgets.dart';

enum _BlinkStage { introduction, recording, result }

class BlinkScreen extends StatefulWidget {
  const BlinkScreen({super.key, required this.patient, required this.answers});
  final PatientProfile patient;
  final List<int> answers;

  @override
  State<BlinkScreen> createState() => _BlinkScreenState();
}

class _BlinkScreenState extends State<BlinkScreen> {
  _BlinkStage _stage = _BlinkStage.introduction;
  Timer? _timer;
  int _secondsLeft = 60;
  int _blinks = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _stage = _BlinkStage.recording;
      _secondsLeft = 60;
      _blinks = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _finish() {
    _timer?.cancel();
    if (_blinks == 0) _blinks = 18;
    setState(() => _stage = _BlinkStage.result);
  }

  int get _rate {
    final elapsed = 60 - _secondsLeft;
    return elapsed < 5 ? _blinks : (_blinks * 60 / elapsed).round();
  }

  void _continue() {
    final result = AssessmentResult(
      patient: widget.patient,
      answers: widget.answers,
      blinksPerMinute: _rate,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TbutScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == _BlinkStage.introduction) {
      return AssessmentScaffold(
        title: 'Blink Rate Analysis',
        bottom: FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.play_arrow_outlined),
          label: const Text('Begin Test'),
        ),
        child: const TestIntroduction(
          icon: Icons.remove_red_eye_outlined,
          title: 'Blink Rate Test',
          description: 'This test measures spontaneous blink rate over 60 seconds. Normal range is 15–20 blinks per minute.',
          steps: [
            "Position the patient facing the front camera at arm's length",
            'Ask the patient to look naturally at the screen and avoid forced blinking',
            'Face landmarks and eye movement will be tracked automatically',
            'The timer runs for 60 seconds',
          ],
          note: 'Front-camera and facial landmark detection will be connected during backend development.',
        ),
      );
    }
    if (_stage == _BlinkStage.recording) {
      return AssessmentScaffold(
        title: 'Recording...',
        scrollable: false,
        bottom: OutlinedButton.icon(
          onPressed: _finish,
          icon: const Icon(Icons.stop_outlined, color: AppColors.danger),
          label: const Text(
            'Stop Early',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
        child: Column(
          children: [
            const CameraPlaceholder(
              title: 'Front Camera View',
              subtitle: 'Face mesh and eye landmarks will appear here',
              height: 270,
            ),
            const Spacer(),
            Text(
              '0:${_secondsLeft.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _blinks++),
              child: Container(
                width: 184,
                height: 184,
                decoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x44139AB0),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$_blinks BLINKS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const Text(
                      'tap to simulate',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Automatic blink detection will replace manual simulation.',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      );
    }
    final elevated = _rate > 20 || _rate < 15;
    return AssessmentScaffold(
      title: 'Blink Rate — Results',
      bottom: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.replay),
              label: const Text('Retry'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _continue,
              child: const Text('Continue to TBUT  ›'),
            ),
          ),
        ],
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
          child: Column(
            children: [
              Text(
                'Blink Rate Result',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_rate',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      height: .9,
                      color: AppColors.ink,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 8),
                    child: Text('blinks/min', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              StatusPill(
                text: elevated ? 'Outside normal range' : 'Normal',
                color: elevated ? AppColors.warning : AppColors.success,
              ),
              const SizedBox(height: 22),
              Text(
                'Detected $_blinks blinks during the test',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Reference: 15–20 blinks/min',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 220),
            ],
          ),
        ),
      ),
    );
  }
}
