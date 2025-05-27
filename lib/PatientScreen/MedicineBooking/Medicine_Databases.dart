import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper1 {
  static final DatabaseHelper1 _instance = DatabaseHelper1._internal();
  factory DatabaseHelper1() => _instance;
  static Database? _database;

  DatabaseHelper1._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'medicine_app.db');

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create medicines table
    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL
      )
    ''');

    // Create cart items table
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        addedDate TEXT NOT NULL,
        FOREIGN KEY (medicineId) REFERENCES medicines (id)
      )
    ''');

    // Insert sample medicines
    await _insertSampleMedicines(db);
  }


  Future<void> _insertSampleMedicines(Database db) async {

  }

  // Medicine CRUD operations
  Future<List<Map<String, dynamic>>> getAllMedicines() async {
    final db = await database;
    return await db.query('medicines');
  }

  // Cart operations
  Future<int> addToCart(int medicineId) async {
    final db = await database;

    // Check if item already exists in cart
    final existingItems = await db.query(
      'cart_items',
      where: 'medicineId = ?',
      whereArgs: [medicineId],
    );

    if (existingItems.isNotEmpty) {
      // Update quantity if exists
      final currentQuantity = existingItems.first['quantity'] as int;
      return await db.update(
        'cart_items',
        {'quantity': currentQuantity + 1},
        where: 'medicineId = ?',
        whereArgs: [medicineId],
      );
    } else {
      // Add new item to cart
      return await db.insert('cart_items', {
        'medicineId': medicineId,
        'quantity': 1,
        'addedDate': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT cart_items.*, medicines.name, medicines.price
      FROM cart_items
      INNER JOIN medicines ON cart_items.medicineId = medicines.id
      ORDER BY cart_items.addedDate DESC
    ''');
  }

  Future<int> removeFromCart(int cartItemId) async {
    final db = await database;
    return await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  Future<int> updateCartItemQuantity(int cartItemId, int newQuantity) async {
    final db = await database;
    return await db.update(
      'cart_items',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }


}
