import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// adb shell "run-as kendedes.douwes.dekker cat /data/user/0/kendedes.douwes.dekker/app_flutter/tagging_app.db" > my_local_db.db
class LocalDatabaseProvider {
  static final LocalDatabaseProvider _instance =
      LocalDatabaseProvider._internal();
  factory LocalDatabaseProvider() => _instance;

  LocalDatabaseProvider._internal();

  bool _initialized = false;
  late Database _database;

  Future<void> init() async {
    if (_initialized) return;
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = '${documentsDirectory.path}/tagging_app.db';
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
    _initialized = true;
  }

  Database get db {
    if (!_initialized) {
      throw Exception("Database not initialized. Call init() first.");
    }
    return _database;
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 1. Organizations
    await db.execute('''
    CREATE TABLE organizations (
      id TEXT PRIMARY KEY,
      short_code TEXT,
      long_code TEXT,
      name TEXT
    )
  ''');

    // 2. User Roles
    await db.execute('''
    CREATE TABLE user_roles (
      id TEXT PRIMARY KEY,
      name TEXT
    )
  ''');

    // 3. Users
    await db.execute('''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      email TEXT,
      firstname TEXT,
      organization_id TEXT,
      FOREIGN KEY(organization_id) REFERENCES organizations(id)
    )
  ''');

    // 4. User-Role Pivot
    await db.execute('''
    CREATE TABLE user_role_pivot (
      user_id TEXT,
      role_id TEXT,
      PRIMARY KEY (user_id, role_id),
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(role_id) REFERENCES user_roles(id)
    )
  ''');

    // 5. Projects
    await db.execute('''
    CREATE TABLE projects (
      id TEXT PRIMARY KEY,
      name TEXT,
      description TEXT,
      created_at TEXT,
      updated_at TEXT,
      deleted_at TEXT,
      type TEXT,
      user_id TEXT,
      FOREIGN KEY(user_id) REFERENCES users(id)
    )
  ''');

    // 6. Tag Data
    await db.execute('''
    CREATE TABLE tag_data (
      id TEXT PRIMARY KEY,
      position_lat REAL,
      position_lng REAL,
      has_changed INTEGER,
      has_sent_to_server INTEGER,
      tag_type TEXT,
      initial_position_lat REAL,
      initial_position_lng REAL,
      is_deleted INTEGER,
      created_at TEXT,
      updated_at TEXT,
      deleted_at TEXT,
      incremental_id INTEGER,
      project_id TEXT,
      business_name TEXT,
      business_owner TEXT,
      business_address TEXT,
      building_status TEXT,
      description TEXT,
      sector TEXT,
      note TEXT,
      user_id TEXT,
      FOREIGN KEY(project_id) REFERENCES projects(id),
      FOREIGN KEY(user_id) REFERENCES users(id)
    )
  ''');
  }
}
