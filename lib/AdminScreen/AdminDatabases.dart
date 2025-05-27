import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Admin_Model.dart'; // make sure this file exists

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'doctors.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE doctors (
            doctorId TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            specialization TEXT,
            experience TEXT,
            address TEXT,
            visitingHours TEXT,
            phone TEXT
          )
        ''');
      },
    );
  }

  // INSERT Doctor
  Future<void> insertDoctor(Doctor doctor) async {
    final db = await database;
    await db.insert(
      'doctors',
      doctor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // GET ALL DOCTORS
  Future<List<Doctor>> getAllDoctors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('doctors');

    return List.generate(maps.length, (i) {
      return Doctor(
        doctorId: maps[i]['doctorId'],
        name: maps[i]['name'],
        email: maps[i]['email'],
        specialization: maps[i]['specialization'],
        experience: maps[i]['experience'],
        address: maps[i]['address'],
        visitingHours: maps[i]['visitingHours'],
        phone: maps[i]['phone'],
      );
    });
  }

  // GET DOCTOR BY EMAIL
  Future<Doctor?> getDoctorByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return Doctor.fromMap(maps.first);
    }
    return null;
  }
  
  Future<Doctor?>getDoctorById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>>maps = await db.query(
      'doctors',
      where: 'doctorId=?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Doctor(
        doctorId: maps[0]['doctorId'],
        name: maps[0]['name'],
        email: maps[0]['email'],
        specialization: maps[0]['specialization'],
        experience: maps[0]['experience'],
        address: maps[0]['address'],
        visitingHours: maps[0]['visitingHours'],
        phone: maps[0]['phone'],
      );
    }
    return null;
  }


    Future<int>updateDoctor(Doctor doctor) async{
    final db=await database;
    return await db.update(
      'doctors',
      doctor.toMap(),
      where: 'doctorId=?',
      whereArgs: [doctor.doctorId],
    );
    }

    Future<int>deleteDoctor(String doctorId) async{
    final db=await database;
    return await db.delete(
      'doctors',
      where: 'doctorId=?',
      whereArgs: [doctorId],
    );
    }
}

