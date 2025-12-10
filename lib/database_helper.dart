import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Provides abstract interface for database operations (Infrastructure)
abstract class DatabaseInterface {
  Future<Database> get database;
  Future<int> insert(String table, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<Object?>? whereArgs});
  Future<int> update(String table, Map<String, dynamic> data, {required String where, required List<Object?> whereArgs});
  Future<int> delete(String table, {required String where, required List<Object?> whereArgs});
}

// Concrete implementation (Infrastructure)
class DatabaseHelper implements DatabaseInterface {
  static const String dbName = 'spendlite_db.db';
  static const int dbVersion = 1;

  Database? _database;

  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    return openDatabase(
      path,
      version: dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date INTEGER NOT NULL,
            description TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs, orderBy: 'date DESC');
  }

  @override
  Future<int> update(String table, Map<String, dynamic> data, {required String where, required List<Object?> whereArgs}) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(String table, {required String where, required List<Object?> whereArgs}) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }
}

// Riverpod Provider for accessing the DB helper globally
final databaseHelperProvider = Provider<DatabaseInterface>((ref) => DatabaseHelper());