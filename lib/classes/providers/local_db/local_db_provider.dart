import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// adb shell "run-as kendedes.douwes.dekker cat /data/user/0/kendedes.douwes.dekker/app_flutter/tagging_app.db" > my_local_db.db
class LocalDbProvider {
  static final LocalDbProvider _instance = LocalDbProvider._internal();
  factory LocalDbProvider() => _instance;

  LocalDbProvider._internal();

  bool _initialized = false;
  late Database _database;

  Future<void> init() async {
    if (_initialized) return;
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = '${documentsDirectory.path}/tagging_app.db';
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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

    // 7. Create polygons table
    await db.execute('''
        CREATE TABLE polygons (
          id TEXT PRIMARY KEY,
          full_name TEXT,
          short_name TEXT,
          type TEXT
        )
      ''');

    // 8. Create polygon_points table
    await db.execute('''
        CREATE TABLE polygon_points (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL,
          longitude REAL,
          polygon_id TEXT,
          FOREIGN KEY(polygon_id) REFERENCES polygons(id)
        )
      ''');

    // 9. Create project_polygons many-to-many table
    await db.execute('''
        CREATE TABLE project_polygons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          project_id TEXT,
          polygon_id TEXT,
          FOREIGN KEY(project_id) REFERENCES projects(id),
          FOREIGN KEY(polygon_id) REFERENCES polygons(id)
        )
      ''');

    // 10. Create regencies table
    await db.execute('''
        CREATE TABLE regencies (
          id TEXT PRIMARY KEY,
          short_code TEXT,
          long_code TEXT,
          name TEXT
        )
      ''');

    // 11. Create subdistricts table
    await db.execute('''
        CREATE TABLE subdistricts (
          id TEXT PRIMARY KEY,
          short_code TEXT,
          long_code TEXT,
          name TEXT,
          regency_id TEXT,
          FOREIGN KEY(regency_id) REFERENCES regencies(id)
        )
      ''');

    // 12. Create villages table
    await db.execute('''
        CREATE TABLE villages (
          id TEXT PRIMARY KEY,
          short_code TEXT,
          long_code TEXT,
          name TEXT,
          subdistrict_id TEXT,
          FOREIGN KEY(subdistrict_id) REFERENCES subdistricts(id)
        )
      ''');

    // 13. Create sls table
    await db.execute('''
        CREATE TABLE sls (
          id TEXT PRIMARY KEY,
          short_code TEXT,
          long_code TEXT,
          name TEXT,
          village_id TEXT,
          FOREIGN KEY(village_id) REFERENCES villages(id)
        )
      ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Create polygons table
      await db.execute('''
        CREATE TABLE polygons (
          id TEXT PRIMARY KEY,
          full_name TEXT,
          short_name TEXT,
          type TEXT
        )
      ''');

      // Create polygon_points table
      await db.execute('''
        CREATE TABLE polygon_points (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL,
          longitude REAL,
          polygon_id TEXT,
          FOREIGN KEY(polygon_id) REFERENCES polygons(id)
        )
      ''');

      // Create project_polygons many-to-many table
      await db.execute('''
        CREATE TABLE project_polygons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          project_id TEXT,
          polygon_id TEXT,
          FOREIGN KEY(project_id) REFERENCES projects(id),
          FOREIGN KEY(polygon_id) REFERENCES polygons(id)
        )
      ''');

      // Create regencies table
      await db.execute('''
        CREATE TABLE regencies (
          id TEXT PRIMARY KEY,
          short_code TEXT,
          long_code TEXT,
          name TEXT
        )
      ''');

      // Create subdistricts table
      await db.execute('''
        CREATE TABLE subdistricts (
          id TEXT PRIMARY KEY,
          short_code TEXT,
          long_code TEXT,
          name TEXT,
          regency_id TEXT,
          FOREIGN KEY(regency_id) REFERENCES regencies(id)
        )
      ''');

      // Create villages table
      await db.execute('''
        CREATE TABLE villages (
          id TEXT PRIMARY KEY,
          short_code TEXT,
          long_code TEXT,
          name TEXT,
          subdistrict_id TEXT,
          FOREIGN KEY(subdistrict_id) REFERENCES subdistricts(id)
        )
      ''');

      // Create sls table
      await db.execute('''
        CREATE TABLE sls (
          id TEXT PRIMARY KEY,
          short_code TEXT,
          long_code TEXT,
          name TEXT,
          village_id TEXT,
          FOREIGN KEY(village_id) REFERENCES villages(id)
        )
      ''');
    }
  }
}
