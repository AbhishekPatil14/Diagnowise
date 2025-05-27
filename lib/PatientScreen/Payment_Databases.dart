import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'MedicineBooking/Model/Payment_Model.dart';

class DatabaseHelper3 {
  static final DatabaseHelper3 instance = DatabaseHelper3._init();
  static Database? _database;

  DatabaseHelper3._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('payments.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        customer_address TEXT NOT NULL,
        items TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertPayment(Payment payment) async {
    final db = await instance.database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await instance.database;
    final maps = await db.query('payments', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}