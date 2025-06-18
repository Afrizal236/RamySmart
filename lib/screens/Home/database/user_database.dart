import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class UserProfile {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? imagePath;

  UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.imagePath,
  });

  // Convert a UserProfile into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'imagePath': imagePath,
    };
  }

  // Create a UserProfile from a Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      imagePath: map['imagePath'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, filePath);
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      // Fallback to temporary directory
      final Directory tempDirectory = await getTemporaryDirectory();
      final String path = join(tempDirectory.path, filePath);
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        imagePath TEXT
      )
    ''');

    // Insert default user
    await db.insert('users', {
      'name': 'Afrizal Ramy Diaman',
      'email': 'ramyhandsomeboy@example.com',
      'phone': '+62 812 3456 7890',
      'imagePath': null,
    });
  }

  // CRUD operations

  // Create
  Future<int> insertUser(UserProfile user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  // Read
  Future<UserProfile?> getUser(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<UserProfile?> getFirstUser() async {
    final db = await instance.database;
    final maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Update
  Future<int> updateUser(UserProfile user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Update user with ID 1 (our default user)
  Future<int> updateDefaultUser(UserProfile user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = 1',
    );
  }

  // Delete
  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Save profile image path
  Future<void> saveProfileImagePath(String imagePath) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'imagePath': imagePath},
      where: 'id = 1', // Assuming we always use the default user
    );
  }

  // Get profile image path
  Future<String?> getProfileImagePath() async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      columns: ['imagePath'],
      where: 'id = 1',
    );

    if (result.isNotEmpty && result.first['imagePath'] != null) {
      return result.first['imagePath'] as String;
    }
    return null;
  }
}