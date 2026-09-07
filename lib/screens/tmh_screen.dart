import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:optik_suly/models/assessment.dart';
import 'package:optik_suly/screens/results_screen.dart';
import 'package:optik_suly/services/app_database.dart';
import 'package:optik_suly/theme/app_theme.dart';
import 'package:optik_suly/widgets/assessment_widgets.dart';
import 'package:optik_suly/widgets/live_camera_view.dart';

enum _TmhStage { introduction, calibration, measurement, result }

class TmhScreen extends StatefulWidget {
  const TmhScreen({super.key, required this.result});
  final AssessmentResult result;

  @override
  State<TmhScreen> createState() => _TmhScreenState();
}

class _TmhScreenState extends State<TmhScreen> {
  _TmhStage _stage = _TmhStage.introduction;
  bool _rightEye = false;
  double _upper = .35;
  double _lower = .64;
  double? _left;
  double? _right;

  double get _measurement => ((_lower - _upper).abs() * .82).clamp(.05, .60);

  void _record() {
    setState(() {
      if (_rightEye) {
        _right = _measurement;
        _stage = _TmhStage.result;
      } else {
        _left = _measurement;
        _rightEye = true;
        _upper = .38;
        _lower = .65;
      }
    });
  }

  Future<void> _finish() async {
    final result = AssessmentResult(
      patient: widget.result.patient,
      answers: widget.result.answers,
      blinksPerMinute: widget.result.blinksPerMinute,
      leftTbut: widget.result.leftTbut,
      rightTbut: widget.result.rightTbut,
      leftTmh: _left ?? .24,
      rightTmh: _right ?? .22,
      completedAt: DateTime.now(),
    );

    // Save assessment to local SQLite database
    try {
      await AppDatabase.instance.saveAssessment(result);
    } catch (e) {
      debugPrint('Failed to save assessment: $e');
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == _TmhStage.introduction) {
      return AssessmentScaffold(
        title: 'Tear Meniscus Height',
        bottom: FilledButton.icon(
          onPressed: () => setState(() => _stage = _TmhStage.calibration),
          icon: const Icon(Icons.straighten_outlined),
          label: const Text('Begin Calibration'),
        ),
        child: const TestIntroduction(
          icon: Icons.straighten_outlined,
          title: 'TMH Measurement',
          description: 'Measures the height of the tear meniscus along the lower eyelid margin using an on-screen digital caliper.',
          steps: [
            "Calibrate by measuring the patient's iris diameter (≈11.7 mm average)",
            'Position the rear camera to view the lower lid tear meniscus',
            'Drag the two caliper lines to bracket the tear meniscus height',
            'The pixel distance is converted to millimeters',
          ],
          note: 'The camera image and measurement are mocked in this front-end version.',
        ),
      );
    }
    if (_stage == _TmhStage.calibration) {
      return AssessmentScaffold(
        title: 'TMH — Calibration',
        bottom: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() {
                  _upper = .35;
                  _lower = .64;
                }),
                icon: const Icon(Icons.replay),
                label: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => setState(() => _stage = _TmhStage.measurement),
                child: const Text('Confirm Calibration'),
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calibration Step',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Position the camera to view the iris. Drag the two lines to span the iris diameter (top to bottom).',
            ),
            const SizedBox(height: 24),
            _CaliperCamera(
              upper: _upper,
              lower: _lower,
              onUpperChanged: (value) => setState(() => _upper = value),
              onLowerChanged: (value) => setState(() => _lower = value),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Calibration reference: 11.7 mm iris diameter',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }
    if (_stage == _TmhStage.measurement) {
      return AssessmentScaffold(
        title: 'TMH — ${_rightEye ? 'Right' : 'Left'} Eye',
        bottom: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() {
                  _upper = .38;
                  _lower = .64;
                }),
                icon: const Icon(Icons.replay),
                label: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _record,
                child: Text(_rightEye ? 'View Results' : 'Record Measurement'),
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _rightEye ? '◉  Right Eye' : '◉  Left Eye',
              style: const TextStyle(
                color: AppColors.tealDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Drag the caliper lines to bracket the tear meniscus height along the lower lid margin.',
            ),
            const Text(
              'Calibrated: 7.7 px/mm',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            _CaliperCamera(
              upper: _upper,
              lower: _lower,
              onUpperChanged: (value) => setState(() => _upper = value),
              onLowerChanged: (value) => setState(() => _lower = value),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                '${_measurement.toStringAsFixed(2)} mm',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final left = _left ?? .24;
    final right = _right ?? .22;
    return AssessmentScaffold(
      title: 'TMH — Results',
      bottom: FilledButton(
        onPressed: _finish,
        child: const Text('View Results  ›'),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Text(
                'TMH Results',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _EyeResult(label: 'Left Eye', value: left),
                  ),
                  const SizedBox(height: 110, child: VerticalDivider()),
                  Expanded(
                    child: _EyeResult(label: 'Right Eye', value: right),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Reference: ≥0.20 mm is normal',
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

class _CaliperCamera extends StatelessWidget {
  const _CaliperCamera({
    required this.upper,
    required this.lower,
    required this.onUpperChanged,
    required this.onLowerChanged,
  });
  final double upper;
  final double lower;
  final ValueChanged<double> onUpperChanged;
  final ValueChanged<double> onLowerChanged;

  @override
  Widget build(BuildContext context) {
    return LiveCameraView(
      height: 420,
      lensDirection: CameraLensDirection.back,
      overlay: LayoutBuilder(
        builder: (context, size) => Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: size.maxHeight * upper - 24,
              child: Slider(
                value: upper,
                min: .15,
                max: .78,
                activeColor: Colors.cyanAccent,
                onChanged: onUpperChanged,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: size.maxHeight * lower - 24,
              child: Slider(
                value: lower,
                min: .20,
                max: .85,
                activeColor: Colors.cyanAccent,
                onChanged: onLowerChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EyeResult extends StatelessWidget {
  const _EyeResult({required this.label, required this.value});
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) {
    final normal = value >= .2;
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text(
          '${value.toStringAsFixed(2)} mm',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        StatusPill(
          text: normal ? 'Normal' : 'Low',
          color: normal ? AppColors.success : AppColors.warning,
        ),
      ],
    );
  }
}
