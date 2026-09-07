import 'dart:convert';

class PatientProfile {
  const PatientProfile({
    required this.name,
    required this.age,
    required this.gender,
    this.notes = '',
  });

  final String name;
  final int age;
  final String gender;
  final String notes;
}

class OsdiQuestion {
  const OsdiQuestion({
    required this.section,
    required this.heading,
    required this.text,
  });

  final String section;
  final String heading;
  final String text;
}

const defaultQuestions = <OsdiQuestion>[
  OsdiQuestion(
    section: 'A',
    heading: 'OCULAR SYMPTOMS',
    text: 'Eyes that are sensitive to light?',
  ),
  OsdiQuestion(
    section: 'A',
    heading: 'OCULAR SYMPTOMS',
    text: 'Eyes that feel gritty or sandy?',
  ),
  OsdiQuestion(
    section: 'A',
    heading: 'OCULAR SYMPTOMS',
    text: 'Painful or sore eyes?',
  ),
  OsdiQuestion(
    section: 'A',
    heading: 'OCULAR SYMPTOMS',
    text: 'Blurred or poor vision?',
  ),
  OsdiQuestion(
    section: 'B',
    heading: 'VISION-RELATED FUNCTION',
    text: 'Difficulty reading for a sustained period?',
  ),
  OsdiQuestion(
    section: 'B',
    heading: 'VISION-RELATED FUNCTION',
    text: 'Difficulty driving at night?',
  ),
  OsdiQuestion(
    section: 'B',
    heading: 'VISION-RELATED FUNCTION',
    text: 'Difficulty using a phone or computer?',
  ),
  OsdiQuestion(
    section: 'C',
    heading: 'ENVIRONMENTAL TRIGGERS',
    text: 'Eye discomfort in windy conditions?',
  ),
  OsdiQuestion(
    section: 'C',
    heading: 'ENVIRONMENTAL TRIGGERS',
    text: 'Eye discomfort in very dry places?',
  ),
  OsdiQuestion(
    section: 'C',
    heading: 'ENVIRONMENTAL TRIGGERS',
    text: 'Eye discomfort in air-conditioned rooms?',
  ),
];

class AssessmentResult {
  const AssessmentResult({
    this.id,
    required this.patient,
    required this.answers,
    this.blinksPerMinute = 18,
    this.leftTbut = 9.4,
    this.rightTbut = 10.8,
    this.leftTmh = 0.24,
    this.rightTmh = 0.22,
    this.completedAt,
  });

  final int? id;
  final PatientProfile patient;
  final List<int> answers;
  final int blinksPerMinute;
  final double leftTbut;
  final double rightTbut;
  final double leftTmh;
  final double rightTmh;
  final DateTime? completedAt;

  double get osdiScore => answers.isEmpty
      ? 0
      : answers.reduce((a, b) => a + b) * 25 / answers.length;

  /// Converts to a map suitable for SQLite insertion.
  Map<String, dynamic> toMap() => {
        'patient_name': patient.name,
        'age': patient.age,
        'gender': patient.gender,
        'clinical_notes': patient.notes,
        'questionnaire_answers': jsonEncode(answers),
        'osdi_score': osdiScore,
        'blinks_per_minute': blinksPerMinute,
        'left_tbut': leftTbut,
        'right_tbut': rightTbut,
        'left_tmh': leftTmh,
        'right_tmh': rightTmh,
        'completed_at':
            (completedAt ?? DateTime.now()).toIso8601String(),
      };

  /// Reconstructs an [AssessmentResult] from a database row.
  factory AssessmentResult.fromMap(Map<String, dynamic> map) {
    final answers = (jsonDecode(map['questionnaire_answers'] as String) as List)
        .cast<int>();
    return AssessmentResult(
      id: map['id'] as int?,
      patient: PatientProfile(
        name: map['patient_name'] as String,
        age: map['age'] as int,
        gender: map['gender'] as String,
        notes: (map['clinical_notes'] as String?) ?? '',
      ),
      answers: answers,
      blinksPerMinute: map['blinks_per_minute'] as int,
      leftTbut: (map['left_tbut'] as num).toDouble(),
      rightTbut: (map['right_tbut'] as num).toDouble(),
      leftTmh: (map['left_tmh'] as num).toDouble(),
      rightTmh: (map['right_tmh'] as num).toDouble(),
      completedAt: DateTime.tryParse(map['completed_at'] as String? ?? ''),
    );
  }
}
