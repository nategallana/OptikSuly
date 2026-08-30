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
    required this.patient,
    required this.answers,
    this.blinksPerMinute = 18,
    this.leftTbut = 9.4,
    this.rightTbut = 10.8,
    this.leftTmh = 0.24,
    this.rightTmh = 0.22,
  });

  final PatientProfile patient;
  final List<int> answers;
  final int blinksPerMinute;
  final double leftTbut;
  final double rightTbut;
  final double leftTmh;
  final double rightTmh;

  double get osdiScore => answers.isEmpty
      ? 0
      : answers.reduce((a, b) => a + b) * 25 / answers.length;
}
