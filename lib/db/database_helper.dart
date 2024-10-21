import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Set the path to the database
    String path = join(await getDatabasesPath(), 'contacts_app.db');

    // Open the database, creating it if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create contacts table
        await db.execute('''
          CREATE TABLE contacts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            pseudo TEXT,
            phoneNumber TEXT
          )
        ''');

        // Create users table
        await db.execute('''
          CREATE TABLE users(
            username TEXT PRIMARY KEY,
            password TEXT,
            address TEXT,
            birthday TEXT
          )
        ''');
      },
    );
  }

Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');

    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  } 

  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Users CRUD operations
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null; // Return null if user not found
    }
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<void> deleteUser(String username) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
  }
}
