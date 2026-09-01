import 'package:flutter/material.dart';
import 'package:optik_suly/models/assessment.dart';
import 'package:optik_suly/screens/home_screen.dart';
import 'package:optik_suly/theme/app_theme.dart';
import 'package:optik_suly/widgets/assessment_widgets.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.result});
  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final abnormalCount = [
      result.osdiScore >= 23,
      result.blinksPerMinute < 15 || result.blinksPerMinute > 20,
      result.leftTbut < 10 || result.rightTbut < 10,
      result.leftTmh < .2 || result.rightTmh < .2,
    ].where((value) => value).length;
    final concern = abnormalCount >= 2;
    return AssessmentScaffold(
      title: 'Assessment Results',
      bottom: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Assessment saved locally to database. PDF export coming soon!'),
                ),
              ),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Export'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              ),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to Home'),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.patient.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Age ${result.patient.age}  •  ${result.patient.gender}',
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Completed ${DateTime.now().toLocal().toString().substring(0, 16)}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: concern
                  ? const Color(0xFFFFF0F2)
                  : const Color(0xFFEFFFF7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: concern
                    ? const Color(0xFFF2B6BF)
                    : const Color(0xFFAAE2CA),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  concern
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  size: 42,
                  color: concern ? AppColors.danger : AppColors.success,
                ),
                const SizedBox(height: 12),
                const Text(
                  'OVERALL ASSESSMENT',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  concern ? 'Dry Eye Signs Detected' : 'Within Normal Range',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: concern ? AppColors.danger : AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  concern
                      ? '$abnormalCount parameters need review. Further clinical evaluation is recommended.'
                      : 'No significant abnormalities were found in this screening.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Individual Parameters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          _ResultCard(
            icon: Icons.assignment_outlined,
            title: 'OSDI Score',
            value: result.osdiScore.toStringAsFixed(1),
            unit: '/ 100',
            normal: result.osdiScore < 23,
            note: result.osdiScore < 23
                ? 'Normal symptom score'
                : 'Elevated dry-eye symptom score',
          ),
          const SizedBox(height: 12),
          _ResultCard(
            icon: Icons.remove_red_eye_outlined,
            title: 'Blink Rate',
            value: '${result.blinksPerMinute}',
            unit: 'blinks/min',
            normal:
                result.blinksPerMinute >= 15 && result.blinksPerMinute <= 20,
            note: 'Reference: 15–20 blinks/min',
          ),
          const SizedBox(height: 12),
          _ResultCard(
            icon: Icons.timer_outlined,
            title: 'Tear Break-Up Time',
            value:
                'L:${result.leftTbut.toStringAsFixed(1)} / R:${result.rightTbut.toStringAsFixed(1)}',
            unit: 'sec',
            normal: result.leftTbut >= 10 && result.rightTbut >= 10,
            note: 'Normal: ≥10 seconds',
          ),
          const SizedBox(height: 12),
          _ResultCard(
            icon: Icons.straighten_outlined,
            title: 'Tear Meniscus Height',
            value:
                'L:${result.leftTmh.toStringAsFixed(2)} / R:${result.rightTmh.toStringAsFixed(2)}',
            unit: 'mm',
            normal: result.leftTmh >= .2 && result.rightTmh >= .2,
            note: 'Normal: ≥0.20 mm',
          ),
          const SizedBox(height: 20),
          const Text(
            'Screening support only — results do not replace diagnosis by a qualified eye-care professional.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.normal,
    required this.note,
  });
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final bool normal;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.tealDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusPill(
                  text: normal ? 'Normal' : 'Review',
                  color: normal ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(unit),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: TextStyle(
                color: normal ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
