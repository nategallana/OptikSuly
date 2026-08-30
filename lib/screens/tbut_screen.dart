import 'dart:async';

import 'package:flutter/material.dart';
import 'package:optik_suly/models/assessment.dart';
import 'package:optik_suly/screens/tmh_screen.dart';
import 'package:optik_suly/theme/app_theme.dart';
import 'package:optik_suly/widgets/assessment_widgets.dart';

enum _TbutStage { introduction, trials, result }

class TbutScreen extends StatefulWidget {
  const TbutScreen({super.key, required this.result});
  final AssessmentResult result;

  @override
  State<TbutScreen> createState() => _TbutScreenState();
}

class _TbutScreenState extends State<TbutScreen> {
  _TbutStage _stage = _TbutStage.introduction;
  final List<double> _left = [];
  final List<double> _right = [];
  bool _rightEye = false;
  bool _running = false;
  int _tenths = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<double> get _active => _rightEye ? _right : _left;

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() {
        _running = false;
        _active.add(_tenths / 10);
        _tenths = 0;
        if (_left.length == 3 && _right.length == 3) _stage = _TbutStage.result;
      });
      return;
    }
    if (_active.length >= 3) return;
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() => _tenths++);
    });
  }

  void _demoResults() {
    setState(() {
      _left
        ..clear()
        ..addAll([9.2, 9.7, 9.3]);
      _right
        ..clear()
        ..addAll([10.5, 10.9, 11.0]);
      _stage = _TbutStage.result;
    });
  }

  double _average(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  void _continue() {
    final result = AssessmentResult(
      patient: widget.result.patient,
      answers: widget.result.answers,
      blinksPerMinute: widget.result.blinksPerMinute,
      leftTbut: _average(_left),
      rightTbut: _average(_right),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TmhScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == _TbutStage.introduction) {
      return AssessmentScaffold(
        title: 'Tear Break-Up Time',
        bottom: FilledButton.icon(
          onPressed: () => setState(() => _stage = _TbutStage.trials),
          icon: const Icon(Icons.play_arrow_outlined),
          label: const Text('Begin TBUT Test'),
        ),
        child: const TestIntroduction(
          icon: Icons.timer_outlined,
          title: 'TBUT Measurement',
          description: 'Measures tear film stability from a complete blink to the first tear film breakup using fluorescein dye under blue light.',
          steps: [
            "Apply fluorescein dye to the patient's lower conjunctival sac",
            "Illuminate with blue light and observe through the rear camera",
            'Ask the patient to blink completely, then hold eyes open',
            'Frame analysis detects the first dark breakup area',
            'Record 3 trials per eye for accuracy',
          ],
          note: 'Normal TBUT is ≥10 seconds. Values below 10 seconds may indicate evaporative dry eye.',
        ),
      );
    }
    if (_stage == _TbutStage.trials) {
      return AssessmentScaffold(
        title: 'TBUT — ${_rightEye ? 'Right' : 'Left'} Eye',
        bottom: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _demoResults,
                child: const Text('Demo Data'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _toggleTimer,
                style: FilledButton.styleFrom(
                  backgroundColor: _running
                      ? AppColors.danger
                      : AppColors.success,
                ),
                icon: Icon(_running ? Icons.stop : Icons.play_arrow),
                label: Text(_running ? 'STOP & RECORD' : 'START'),
              ),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _EyeTab(
                      label: 'Left Eye (${_left.length}/3)',
                      selected: !_rightEye,
                      onTap: () => setState(() => _rightEye = false),
                    ),
                  ),
                  Expanded(
                    child: _EyeTab(
                      label: 'Right Eye (${_right.length}/3)',
                      selected: _rightEye,
                      onTap: () => setState(() => _rightEye = true),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const CameraPlaceholder(
              title: 'Rear Camera View',
              subtitle: 'Eye region and tear-film mask will appear here',
              height: 210,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Text(
                      'TRIAL ${(_active.length + 1).clamp(1, 3)} OF 3',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      (_tenths / 10).toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        height: .9,
                        color: AppColors.ink,
                      ),
                    ),
                    const Text('seconds', style: TextStyle(fontSize: 17)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_rightEye ? 'Right' : 'Left'} Eye Trials',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _active.isEmpty
                            ? 'No trials recorded yet'
                            : _active
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) =>
                                        'Trial ${entry.key + 1}: ${entry.value.toStringAsFixed(1)} sec',
                                  )
                                  .join('   •   '),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final left = _average(_left);
    final right = _average(_right);
    return AssessmentScaffold(
      title: 'TBUT — Results',
      bottom: FilledButton(
        onPressed: _continue,
        child: const Text('Continue to TMH  ›'),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Text(
                'TBUT Results',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: 'Left Eye',
                      value: '${left.toStringAsFixed(1)} sec',
                    ),
                  ),
                  const SizedBox(height: 20, child: VerticalDivider()),
                  Expanded(
                    child: _Metric(
                      label: 'Right Eye',
                      value: '${right.toStringAsFixed(1)} sec',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StatusPill(
                text: left < 10 || right < 10 ? 'Review recommended' : 'Normal',
                color: left < 10 || right < 10
                    ? AppColors.warning
                    : AppColors.success,
              ),
              const SizedBox(height: 180),
            ],
          ),
        ),
      ),
    );
  }
}

class _EyeTab extends StatelessWidget {
  const _EyeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(11),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.teal : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Text(
        value,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
      ),
    ],
  );
}
