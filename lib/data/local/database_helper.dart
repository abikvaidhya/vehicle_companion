import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'vehicle_companion.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        startTime TEXT NOT NULL,
        endTime TEXT,
        distanceKm REAL NOT NULL DEFAULT 0,
        cost REAL,
        notes TEXT,
        routePointsJson TEXT NOT NULL DEFAULT '[]',
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        dueDate TEXT,
        intervalKm INTEGER,
        lastDone TEXT,
        notes TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Seed a few Swedish-relevant maintenance items
    await db.insert('maintenance', {
      'id': 'seed-oil',
      'title': 'Oil change',
      'dueDate': DateTime.now().add(const Duration(days: 45)).toIso8601String(),
      'intervalKm': 15000,
      'lastDone': null,
      'notes': null,
      'isCompleted': 0,
    });
    await db.insert('maintenance', {
      'id': 'seed-tires',
      'title': 'Tire rotation / inspection',
      'dueDate': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      'intervalKm': 10000,
      'lastDone': null,
      'notes': null,
      'isCompleted': 0,
    });
    await db.insert('maintenance', {
      'id': 'seed-besiktning',
      'title': 'Annual inspection (Besiktning)',
      'dueDate': DateTime.now().add(const Duration(days: 120)).toIso8601String(),
      'intervalKm': null,
      'lastDone': null,
      'notes': 'Swedish vehicle inspection',
      'isCompleted': 0,
    });
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
