import 'package:flutter/material.dart';
import 'package:optik_suly/screens/profile_screen.dart';
import 'package:optik_suly/theme/app_theme.dart';
import 'package:optik_suly/widgets/assessment_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _start(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const modules = [
      (
        Icons.assignment_outlined,
        'OSDI Questionnaire',
        '10-item symptom survey',
      ),
      (
        Icons.remove_red_eye_outlined,
        'Blink Rate Analysis',
        'Automatic blink tracking',
      ),
      (Icons.timer_outlined, 'Tear Break-Up Time', 'Three trials per eye'),
      (
        Icons.straighten_outlined,
        'Tear Meniscus Height',
        'Digital caliper measurement',
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 36, 22, 28),
          children: [
            const Center(
              child: RoundIcon(Icons.remove_red_eye_outlined, size: 92),
            ),
            const SizedBox(height: 20),
            Text(
              'OptikSulyApp',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Comprehensive Dry Eye Disease Assessment',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.tealDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Integrating subjective and objective parameters for accurate DED screening in clinical and outreach settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF555C6A),
              ),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              key: const Key('start-assessment'),
              onPressed: () => _start(context),
              icon: const Icon(Icons.monitor_heart_outlined),
              label: const Text('Start New Assessment'),
            ),
            const SizedBox(height: 30),
            Text(
              'Assessment Modules',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .92,
              ),
              itemBuilder: (_, index) {
                final module = modules[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _start(context),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: AppColors.aqua,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(module.$1, color: AppColors.tealDark),
                          ),
                          const Spacer(),
                          Text(
                            module.$2,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            module.$3,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 17, color: AppColors.muted),
                SizedBox(width: 7),
                Text(
                  'Assessment data stays on this device',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
