import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'primefleet.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Companies table
    await db.execute('''
      CREATE TABLE companies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Vehicles table
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        registration TEXT NOT NULL,
        model TEXT NOT NULL,
        company_id INTEGER NOT NULL,
        FOREIGN KEY (company_id) REFERENCES companies (id) ON DELETE CASCADE,
        UNIQUE(registration, company_id)
      )
    ''');

    // Tyres table
    await db.execute('''
      CREATE TABLE tyres (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tyre_id TEXT NOT NULL,
        position TEXT NOT NULL,
        tread_depth REAL NOT NULL,
        pressure REAL NOT NULL,
        mileage INTEGER NOT NULL,
        condition TEXT NOT NULL,
        last_rotation TEXT NOT NULL,
        notes TEXT,
        vehicle_id INTEGER NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');
  }

  // ---------- Companies ----------
  Future<int> insertCompany(String name) async {
    final db = await database;
    return await db.insert('companies', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getAllCompanies() async {
    final db = await database;
    return await db.query('companies', orderBy: 'name');
  }

  Future<int> updateCompany(int id, String name) async {
    final db = await database;
    return await db.update('companies', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCompany(int id) async {
    final db = await database;
    return await db.delete('companies', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Vehicles ----------
  Future<int> insertVehicle(String registration, String model, int companyId) async {
    final db = await database;
    return await db.insert('vehicles', {
      'registration': registration,
      'model': model,
      'company_id': companyId,
    });
  }

  Future<List<Map<String, dynamic>>> getVehiclesByCompany(int companyId) async {
    final db = await database;
    return await db.query('vehicles', where: 'company_id = ?', whereArgs: [companyId], orderBy: 'registration');
  }

  Future<int> updateVehicle(int id, String registration, String model) async {
    final db = await database;
    return await db.update('vehicles', {'registration': registration, 'model': model}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getVehicleById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('vehicles', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // ---------- Tyres ----------
  Future<int> insertTyre(Map<String, dynamic> tyre) async {
    final db = await database;
    return await db.insert('tyres', tyre);
  }

  Future<List<Map<String, dynamic>>> getTyresByVehicle(int vehicleId) async {
    final db = await database;
    return await db.query('tyres', where: 'vehicle_id = ?', whereArgs: [vehicleId], orderBy: 'tyre_id');
  }

  Future<int> updateTyre(int id, Map<String, dynamic> tyre) async {
    final db = await database;
    return await db.update('tyres', tyre, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTyre(int id) async {
    final db = await database;
    return await db.delete('tyres', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> searchTyres(String keyword, {int? vehicleId}) async {
    final db = await database;
    String sql = '''
      SELECT t.*, v.registration, v.model, c.name as company_name
      FROM tyres t
      JOIN vehicles v ON t.vehicle_id = v.id
      JOIN companies c ON v.company_id = c.id
      WHERE t.tyre_id LIKE ? OR t.position LIKE ? OR t.notes LIKE ? OR v.registration LIKE ? OR v.model LIKE ?
    ''';
    final args = ['%$keyword%', '%$keyword%', '%$keyword%', '%$keyword%', '%$keyword%'];
    if (vehicleId != null) {
      sql += ' AND t.vehicle_id = ?';
      args.add(vehicleId.toString());
    }
    return await db.rawQuery(sql, args);
  }
}