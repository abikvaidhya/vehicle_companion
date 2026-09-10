import 'dart:convert';

import '../../domain/models/trip.dart';
import '../local/database_helper.dart';

class TripRepository {
  TripRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  Future<List<Trip>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query('trips', orderBy: 'startTime DESC');
    return rows.map(_fromRow).toList();
  }

  Future<Trip?> getById(String id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('trips', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> insert(Trip trip) async {
    final db = await _dbHelper.database;
    await db.insert('trips', _toRow(trip));
  }

  Future<void> update(Trip trip) async {
    final db = await _dbHelper.database;
    await db.update(
      'trips',
      _toRow(trip),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _toRow(Trip trip) {
    final json = jsonEncode(trip.routePoints.map((p) => p.toMap()).toList());
    return trip.toDbMap(json);
  }

  Trip _fromRow(Map<String, dynamic> row) {
    final jsonStr = row['routePointsJson'] as String? ?? '[]';
    final list = (jsonDecode(jsonStr) as List<dynamic>)
        .map((e) => LatLngPoint.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Trip.fromMap(row, points: list);
  }
}
