import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:optik_suly/models/assessment.dart';

/// Singleton service that manages the local SQLite database.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  /// Returns the open database, creating it on first access.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'optik_suly.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE assessments (
        id                      INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_name            TEXT    NOT NULL,
        age                     INTEGER NOT NULL,
        gender                  TEXT    NOT NULL,
        clinical_notes          TEXT    NOT NULL DEFAULT '',
        questionnaire_answers   TEXT    NOT NULL,
        osdi_score              REAL    NOT NULL,
        blinks_per_minute       INTEGER NOT NULL,
        left_tbut               REAL    NOT NULL,
        right_tbut              REAL    NOT NULL,
        left_tmh                REAL    NOT NULL,
        right_tmh               REAL    NOT NULL,
        completed_at            TEXT    NOT NULL
      )
    ''');
  }

  /// Inserts a completed assessment and returns its row id.
  Future<int> saveAssessment(AssessmentResult result) async {
    final db = await database;
    return db.insert('assessments', result.toMap());
  }

  /// Returns all saved assessments, newest first.
  Future<List<AssessmentResult>> getAssessments() async {
    final db = await database;
    final rows = await db.query(
      'assessments',
      orderBy: 'completed_at DESC',
    );
    return rows.map(AssessmentResult.fromMap).toList();
  }

  /// Deletes the assessment with the given [id].
  Future<int> deleteAssessment(int id) async {
    final db = await database;
    return db.delete('assessments', where: 'id = ?', whereArgs: [id]);
  }
}
