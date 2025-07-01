import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prediction_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    return _database ??= await _initDB('predictions_v2.db');
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        result TEXT,
        imagePath TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT,
        password TEXT,
        confirm_password TEXT
      )
    ''');
  }

  Future<int> insertPrediction(PredictionModel prediction) async {
    final db = await instance.database;
    return await db.insert('predictions', prediction.toMap());
  }

  Future<List<PredictionModel>> getPredictions() async {
    final db = await instance.database;
    final result = await db.query('predictions', orderBy: 'id DESC');
    return result.map((json) => PredictionModel.fromMap(json)).toList();
  }

  Future<int> insertUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
