import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_data.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('family_feud.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        responses TEXT NOT NULL
      )
    ''');
  }

  Future<int> createQuestion(GameQuestion question) async {
    final db = await database;
    
    final data = {
      'question': question.question,
      'responses': jsonEncode(question.responses.map((r) => r.toJson()).toList()),
    };
    
    return await db.insert('questions', data);
  }

  Future<List<GameQuestion>> getAllQuestions() async {
    final db = await database;
    final result = await db.query('questions', orderBy: 'id ASC');
    
    return result.map((json) {
      final responses = (jsonDecode(json['responses'] as String) as List)
          .map((r) => GameResponse.fromJson(r as Map<String, dynamic>))
          .toList();
      
      return GameQuestion(
        question: json['question'] as String,
        responses: responses,
      );
    }).toList();
  }

  Future<int> deleteQuestion(int index) async {
    final db = await database;
    final questions = await db.query('questions', orderBy: 'id ASC');
    
    if (index >= 0 && index < questions.length) {
      final id = questions[index]['id'] as int;
      return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
    }
    
    return 0;
  }

  Future<void> clearAllQuestions() async {
    final db = await database;
    await db.delete('questions');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
