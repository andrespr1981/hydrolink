import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  Database? database;

  Future<Database> get _database async {
    if (database != null) return database!;
    database = await initializeDB('local.db');
    return database!;
  }

  Future initializeDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE humidity(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT,data TEXT);
      ''');
    await db.execute('''
      CREATE TABLE light(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT,data TEXT);
      ''');
    await db.execute('''
      CREATE TABLE dirtHumidity(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT,data TEXT);
      ''');
    await db.execute('''
      CREATE TABLE temperature(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT,data TEXT);
      ''');
  }

  Future addData(String table, String date, String data) async {
    Database db = await _database;
    await db.insert(table, {'date': date, 'data': data});
    return true;
  }

  Future<List<Map<String, dynamic>>> readData(String table) async {
    Database db = await _database;
    final data = await db.query(table, columns: ['date', 'data']);
    return data;
  }

  Future<void> clearAllData() async {
    final db = await _database;
    await db.delete('humidity');
    await db.delete('light');
    await db.delete('dirtHumidity');
    await db.delete('temperature');
  }
}
