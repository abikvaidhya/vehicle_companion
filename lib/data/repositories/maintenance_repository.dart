import '../../domain/models/maintenance_item.dart';
import '../local/database_helper.dart';

class MaintenanceRepository {
  MaintenanceRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  Future<List<MaintenanceItem>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'maintenance',
      orderBy: 'isCompleted ASC, dueDate ASC',
    );
    return rows.map(MaintenanceItem.fromMap).toList();
  }

  Future<void> insert(MaintenanceItem item) async {
    final db = await _dbHelper.database;
    await db.insert('maintenance', item.toMap());
  }

  Future<void> update(MaintenanceItem item) async {
    final db = await _dbHelper.database;
    await db.update(
      'maintenance',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('maintenance', where: 'id = ?', whereArgs: [id]);
  }
}
