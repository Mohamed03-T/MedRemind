import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/medication.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'medication_database.db');
    return await openDatabase(
      path,
      version: 7, // Incremented to version 7 to fix potential migration issues
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        dosage TEXT,
        timeText TEXT,
        frequency TEXT,
        interval INTEGER,
        intervalUnit TEXT,
        totalPills INTEGER,
        endDate TEXT,
        hour INTEGER,
        minute INTEGER,
        year INTEGER,
        month INTEGER,
        day INTEGER,
        isTaken INTEGER,
        sound TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE completions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        medicationId INTEGER
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _safeAddColumn(db, 'medications', 'sound', 'TEXT');
    }
    if (oldVersion < 3) {
      await _safeAddColumn(db, 'medications', 'year', 'INTEGER');
      await _safeAddColumn(db, 'medications', 'month', 'INTEGER');
      await _safeAddColumn(db, 'medications', 'day', 'INTEGER');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS completions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          medicationId INTEGER
        )
      ''');
    }
    if (oldVersion < 5) {
      await _safeAddColumn(db, 'medications', 'interval', 'INTEGER');
      await _safeAddColumn(db, 'medications', 'intervalUnit', 'TEXT');
    }
    if (oldVersion < 7) {
      // Version 6 was supposed to add these, but we ensure it here for version 7
      await _safeAddColumn(db, 'medications', 'totalPills', 'INTEGER');
      await _safeAddColumn(db, 'medications', 'endDate', 'TEXT');
    }
  }

  Future<void> _safeAddColumn(Database db, String table, String column, String type) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (e) {
      // Column might already exist
      debugPrint('Column $column might already exist in $table: $e');
    }
  }

  Future<int> insertMedication(Medication medication) async {
    Database db = await database;
    return await db.insert('medications', medication.toMap());
  }

  Future<List<Medication>> getMedications() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medications');
    return List.generate(maps.length, (i) {
      return Medication.fromMap(maps[i]);
    });
  }

  Future<int> updateMedication(Medication medication) async {
    Database db = await database;
    return await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    Database db = await database;
    return await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertCompletion(String date, int medicationId) async {
    Database db = await database;
    await db.insert('completions', {'date': date, 'medicationId': medicationId});
  }

  Future<void> deleteCompletion(String date, int medicationId) async {
    Database db = await database;
    await db.delete('completions', where: 'date = ? AND medicationId = ?', whereArgs: [date, medicationId]);
  }

  Future<List<int>> getCompletionsForDate(String date) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('completions', where: 'date = ?', whereArgs: [date]);
    return maps.map<int>((m) => m['medicationId'] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getCompletionsForRange(String startDate, String endDate) async {
    Database db = await database;
    return await db.query(
      'completions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
    );
  }

  Future<void> deleteCompletionsForMed(int medicationId) async {
    Database db = await database;
    await db.delete('completions', where: 'medicationId = ?', whereArgs: [medicationId]);
  }

  Future<Medication?> getMedicationById(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Medication.fromMap(maps.first);
  }

  Future<int?> decrementPills(int medicationId) async {
    Database db = await database;
    
    // Get current medication
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [medicationId],
    );

    if (maps.isEmpty) return null;
    
    final med = Medication.fromMap(maps.first);
    if (med.totalPills == null || med.totalPills! <= 0) return med.totalPills;

    final newTotal = med.totalPills! - 1;
    await db.update(
      'medications',
      {'totalPills': newTotal},
      where: 'id = ?',
      whereArgs: [medicationId],
    );
    
    return newTotal;
  }
}
