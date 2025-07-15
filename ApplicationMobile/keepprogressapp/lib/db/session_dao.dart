import 'package:keepprogressapp/models/session_model.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class SessionDao {
  static const table = 'sessions';

  static Future<void> insertAll(List<Session> sessions) async {
    final db = await DatabaseHelper.database;
    await db.delete(table); // clean slate

    for (var session in sessions) {
      await db.insert(table, session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<List<Session>> getAll() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(table);
    return maps.map((m) => Session.fromMap(m)).toList();
  }
}
