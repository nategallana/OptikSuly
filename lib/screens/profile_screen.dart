import 'package:flutter/material.dart';
import 'package:optik_suly/models/assessment.dart';
import 'package:optik_suly/screens/questionnaire_screen.dart';
import 'package:optik_suly/theme/app_theme.dart';
import 'package:optik_suly/widgets/assessment_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _notes = TextEditingController();
  String? _gender;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate() || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the required patient information.'),
        ),
      );
      return;
    }
    final profile = PatientProfile(
      name: _name.text.trim(),
      age: int.parse(_age.text),
      gender: _gender!,
      notes: _notes.text.trim(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuestionnaireScreen(patient: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
    return AssessmentScaffold(
      title: 'Patient Profile',
      bottom: FilledButton(
        onPressed: _continue,
        child: const Text('Continue to OSDI  ›'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  children: [
                    const RoundIcon(Icons.person_outline),
                    const SizedBox(height: 18),
                    Text(
                      'Patient Demographics',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enter the patient's basic information before beginning the assessment.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Full Name *'),
                    TextFormField(
                      key: const Key('patient-name'),
                      controller: _name,
                      decoration: const InputDecoration(
                        hintText: 'Enter patient name',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    const _Label('Age *'),
                    TextFormField(
                      key: const Key('patient-age'),
                      controller: _age,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Enter age'),
                      validator: (value) {
                        final age = int.tryParse(value ?? '');
                        return age == null || age < 1 || age > 120
                            ? 'Enter a valid age'
                            : null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const _Label('Gender'),
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: genders.map((gender) {
                        final selected = _gender == gender;
                        return ChoiceChip(
                          label: Text(gender),
                          selected: selected,
                          selectedColor: AppColors.aqua,
                          side: BorderSide(
                            color: selected ? AppColors.teal : AppColors.border,
                          ),
                          onSelected: (_) => setState(() => _gender = gender),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const _Label('Clinical Notes (Optional)'),
                    TextField(
                      controller: _notes,
                      minLines: 4,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Any relevant clinical history...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
    ),
  );
}
