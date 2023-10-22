import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = 'myDatabase.db';
  static final _dbVersion = 1;
  static final _tableName = 'user';
  static final columnId = '_id';
  static final columnUsername = 'username';
  static final columnPassword = 'password';
  static final columnBalance = 'balance';

  // rend cette classe singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path,
        version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $_tableName (
            $columnId INTEGER PRIMARY KEY,
            $columnUsername TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnBalance REAL NOT NULL
          )
          ''');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryUser(String username) async {
    Database db = await instance.database;
    return await db.query(_tableName,
        where: '$columnUsername = ?',
        whereArgs: [username]);
  }

  Future<int> updateUser(String username, double newBalance) async {
    Database db = await instance.database;
    return await db.update(
        _tableName,
        {columnBalance: newBalance},
        where: '$columnUsername = ?',
        whereArgs: [username]);
  }
}
