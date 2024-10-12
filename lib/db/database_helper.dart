import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';
 

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, pseudo TEXT, phoneNumber TEXT)",
        );
      },
    );
  }

  // Insert a new contact into the database
  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap());
  }

  // Get all contacts from the database
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        name: maps[i]['name'],
        pseudo: maps[i]['pseudo'],
        phoneNumber: maps[i]['phoneNumber'],
      );
    });
  }

  // Define the deleteContact method
  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
