import 'package:flutter/material.dart';
import 'package:optik_suly/models/assessment.dart';
import 'package:optik_suly/screens/blink_screen.dart';
import 'package:optik_suly/theme/app_theme.dart';
import 'package:optik_suly/widgets/assessment_widgets.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key, required this.patient});
  final PatientProfile patient;

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int _index = 0;
  final List<int?> _answers = List<int?>.filled(defaultQuestions.length, null);
  static const labels = [
    'None of the time',
    'Some of the time',
    'Half of the time',
    'Most of the time',
    'All of the time',
  ];

  void _next() {
    if (_answers[_index] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose an answer before continuing.')),
      );
      return;
    }
    if (_index < defaultQuestions.length - 1) {
      setState(() => _index++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlinkScreen(
            patient: widget.patient,
            answers: _answers.cast<int>(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = defaultQuestions[_index];
    final progress = (_index + 1) / defaultQuestions.length;
    return AssessmentScaffold(
      title: 'OSDI Questionnaire',
      scrollable: false,
      bottom: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _index == 0 ? null : () => setState(() => _index--),
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              key: const Key('question-next'),
              onPressed: _next,
              child: Text(
                _index == defaultQuestions.length - 1 ? 'Finish  ›' : 'Next  ›',
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Q${_index + 1}: ${question.heading}',
                style: const TextStyle(
                  color: AppColors.tealDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${_index + 1} / ${defaultQuestions.length}',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: AppColors.border,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '▣  SECTION ${question.section}: ${question.heading}',
                      style: const TextStyle(
                        color: AppColors.tealDark,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'During the last week, how often have you experienced the following?',
                    ),
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.aqua,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Q${_index + 1}',
                            style: const TextStyle(
                              color: AppColors.tealDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.text,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: labels.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, value) => Material(
                          color: _answers[_index] == value
                              ? AppColors.aqua
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          child: RadioListTile<int>(
                            value: value,
                            groupValue: _answers[_index],
                            onChanged: (answer) =>
                                setState(() => _answers[_index] = answer),
                            title: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '$value',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Expanded(child: Text(labels[value])),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}
