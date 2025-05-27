import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'Patient_Model.dart';

class BookingDatabase{
  static final BookingDatabase instance=BookingDatabase._init();
  static Database? _database;

  BookingDatabase._init();

  Future<Database>get database async{
    if(_database!=null) return _database!;
    _database=await _initDB('bookings.db');
    return _database!;
  }

  Future<Database>_initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB,);
  }

  Future _createDB(Database db,int version) async{
    await db.execute('''
    CREATE TABLE bookings(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
     name TEXT,
     phone TEXT,
     email TEXT,
     age TEXT,
     reason TEXT,
     date TEXT,
     time TEXT,
     filePath TEXT,
     doctorName TEXT,
     doctorEmail TEXT,
     status TEXT
    )
    ''');
  }

  Future<int>insertBooking(Booking booking)async{
    final db=await instance.database;
    return await db.insert('bookings', booking.toMap());
  }
  
  Future<List<Booking>>getAllBookings() async{
    final db=await instance.database;
    final result =await db.query('bookings');
    return result.map((map) => Booking.fromMap(map)).toList();
  }

  Future close() async{
    final db=await instance.database;
    db.close();
  }

  Future<int>deleteBooking(int id) async{
    final db=await instance.database;
    return await db.delete('bookings',where: 'id=?',whereArgs: [id]);
  }


  Future<int>updateBooking(Booking booking) async{
    final db=await instance.database;
    return await db.update('bookings',booking.toMap(),where: 'id=?',whereArgs: [booking.id],);
  }


  Future<List<Booking>> getPendingBookings(String doctorEmail) async {
    final db = await instance.database;
    final result = await db.query(
      'bookings',
      where: 'LOWER(status) = ? AND LOWER(doctorEmail) = ?',
      whereArgs: ['pending', doctorEmail.toLowerCase()],
    );
    return result.map((map) => Booking.fromMap(map)).toList();
  }



  Future<List<Booking>>getAcceptedBookings() async{
    final db=await instance.database;
    final result=await db.query('bookings',where: 'status=?',whereArgs:['accepted']);
    return result.map((map) => Booking.fromMap(map)).toList();
  }

  Future<List<Booking>>getDeclinedBookings() async{
    final db=await instance.database;
    final result=await db.query('bookings',where: 'status=?',whereArgs:['declined']);
    return result.map((map) => Booking.fromMap(map)).toList();
  }

  Future<Map<String,int>>getStatusCounts(String doctorEmail) async{
    final db=await instance.database;

    final pendingCountQuery=await db.rawQuery(
      'SELECT COUNT(*) as count FROM bookings WHERE LOWER(status)=? AND LOWER(doctorEmail)=?',
      ['pending',doctorEmail.toLowerCase()]
    );
    final acceptedCountQuery = await db.rawQuery(
        'SELECT COUNT(*) as count FROM bookings WHERE LOWER(status) = ? AND LOWER(doctorEmail) = ?',
        ['accepted', doctorEmail.toLowerCase()]
    );
    final declinedCountQuery = await db.rawQuery(
        'SELECT COUNT(*) as count FROM bookings WHERE LOWER(status) = ? AND LOWER(doctorEmail) = ?',
        ['declined', doctorEmail.toLowerCase()]
    );

    int pending=Sqflite.firstIntValue(pendingCountQuery) ?? 0;
    int accepted=Sqflite.firstIntValue(acceptedCountQuery) ?? 0;
    int declined=Sqflite.firstIntValue(declinedCountQuery) ?? 0;

    return {
      'pending': pending,
      'accepted': accepted,
      'declined': declined,
    };


  }

}