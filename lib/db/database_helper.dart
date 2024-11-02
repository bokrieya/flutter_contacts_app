import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart';
import '../models/contact.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        pseudoName TEXT,
        phoneNumber TEXT,
        userId INTEGER,  -- Add userId to associate contacts with a user
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // Get all users
  Future<List<User>> getUsers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('users');
      return List.generate(maps.length, (i) => User.fromMap(maps[i]));
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  // Insert a new user
  Future<int> insertUser(User user) async {
    try {
      final db = await database;
      return await db.insert('users', user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error inserting user: $e");
      return -1;
    }
  }

  // Create an initial user if not exists
  Future<void> createInitialUserIfNotExists() async {
    try {
      final db = await database;
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['bokri@gmail.com'],
      );

      if (existingUser.isEmpty) {
        await createUser('bokri@gmail.com', 'bokri123', 'bokri');
      }
    } catch (e) {
      print("Error creating initial user: $e");
    }
  }

  // Create a new user
  Future<bool> createUser(String email, String password, String name) async {
    try {
      final db = await database;
      if (db == null) return false;

      final hashedPassword = _hashPassword(password);
      await db.insert('users', {
        'email': email,
        'password': hashedPassword,
        'name': name,
      });
      return true;
    } catch (e) {
      print("Error creating user: $e");
      return false;
    }
  }

  // Authenticate user
  Future<bool> authenticateUser(String email, String password) async {
    try {
      final db = await database;
      if (db == null) return false;

      final hashedPassword = _hashPassword(password);
      final results = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );
      return results.isNotEmpty;
    } catch (e) {
      print("Error during authentication: $e");
      return false;
    }
  }

  // Manage logged-in user with SharedPreferences
  Future<void> setLoggedInUser(String email, bool rememberMe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_user', email);
      await prefs.setBool('remember_me', rememberMe);
    } catch (e) {
      print("Error setting logged in user: $e");
    }
  }

  Future<String?> getLoggedInUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me');
      if (remember != null && !remember) {
        return prefs.getString('logged_in_user');
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting logged in user: $e");
      return null;
    }
  }

  Future<bool> isRememberMeChecked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('remember_me') ?? false;
    } catch (e) {
      print("Error checking remember me: $e");
      return false;
    }
  }

  Future<void> logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('logged_in_user');
      await prefs.remove('remember_me');
    } catch (e) {
      print("Error logging out user: $e");
    }
  }

  // Hash password using SHA-256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Contact CRUD operations
  Future<int> insertContact(Contact contact) async {
    try {
      final db = await database;
      return await db.insert('contacts', {
        ...contact.toMap(),
        // Ensure userId is associated
      });
    } catch (e) {
      print("Error inserting contact: $e");
      return -1;
    }
  }

  Future<List<Contact>> getContacts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'contacts',
        // where: 'userId = ?',
        // whereArgs: [userId],
      );
      return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
    } catch (e) {
      print("Error getting contacts: $e");
      return [];
    }
  }

  Future<int> updateContact(Contact contact) async {
    try {
      final db = await database;
      if (db == null) return 0;
      return await db.update(
        'contacts',
        contact.toMap(),
        where: 'id = ?',
        whereArgs: [contact.id],
      );
    } catch (e) {
      print("Error updating contact: $e");
      return 0;
    }
  }

  Future<int> deleteContact(int id) async {
    try {
      final db = await database;
      if (db == null) return 0;
      return await db.delete(
        'contacts',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting contact: $e");
      return 0;
    }
  }

  // Initialize the database
  Future<void> initializeDatabase() async {
    try {
      final db = await database;
      await createInitialUserIfNotExists();
      print("Database initialized successfully");
    } catch (e) {
      print("Error during database initialization: $e");
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users', // Assuming you have a 'users' table
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first); // Assuming you have a User model
    }

    return null; // Return null if no user is found
  }
}
