import 'package:path/path.dart';
import 'RegistrationScreen/Registration_Model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    return _database ??= await _initDB('user.db');
  }

  Future<UserModel?>getUserByEmail(String email) async{
    final db=await instance.database;
    final result=await db.query(
      'users',
      where:'email= ?',
      whereArgs:[email],
    );
    if(result.isNotEmpty){
      return UserModel.fromMap(result.first);
    }
    return null;
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
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        adminCode TEXT
      )
    ''');
  }

  Future<int> registerUser(UserModel user, String password, String role) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password, String role) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ? AND role = ?',
      whereArgs: [email, password, role],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
