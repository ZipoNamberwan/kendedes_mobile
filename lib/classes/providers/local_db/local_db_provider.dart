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
      version: 6,
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
      interaction_mode TEXT,
      remote_id TEXT,
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
      is_locked INTEGER,
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
      remote_id TEXT,
      sls_id TEXT,
      sls_short_code TEXT,
      sls_long_code TEXT,
      sls_name TEXT,
      village_id TEXT,
      village_short_code TEXT,
      village_long_code TEXT,
      village_name TEXT,
      subdistrict_id TEXT,
      subdistrict_short_code TEXT,
      subdistrict_long_code TEXT,
      subdistrict_name TEXT,
      regency_id TEXT,
      regency_short_code TEXT,
      regency_long_code TEXT,
      regency_name TEXT,
      id_sbr TEXT,
      original_area TEXT,
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
          long_code TEXT,
          short_code TEXT,
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

    // 14. Create sls_with_business table
    await db.execute('''
        CREATE TABLE sls_with_business (
          id TEXT PRIMARY KEY,
          sls_id TEXT,
          sls_short_code TEXT,
          sls_long_code TEXT,
          sls_name TEXT,
          village_id TEXT,
          village_short_code TEXT,
          village_long_code TEXT,
          village_name TEXT,
          subdistrict_id TEXT,
          subdistrict_short_code TEXT,
          subdistrict_long_code TEXT,
          subdistrict_name TEXT,
          regency_id TEXT,
          regency_short_code TEXT,
          regency_long_code TEXT,
          regency_name TEXT,

          business_count INTEGER DEFAULT 0,

          user_id TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id)
        )
      ''');

    // 15. Create user_polygons many-to-many table
    await db.execute('''
        CREATE TABLE user_polygons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          polygon_id TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id),
          FOREIGN KEY(polygon_id) REFERENCES polygons(id)
        )
      ''');

    // 16. Create families table
    await db.execute('''
        CREATE TABLE families (
          id TEXT PRIMARY KEY,
          name TEXT,
          address TEXT,
          created_at TEXT
        )
      ''');

    // 17. Create family_photos table
    await db.execute('''
        CREATE TABLE family_photos (
          id TEXT PRIMARY KEY,
          family_id TEXT,
          type TEXT,
          filename TEXT,
          FOREIGN KEY(family_id) REFERENCES families(id)
        )
      ''');

    // 18. Create infos table
    await db.execute('''
        CREATE TABLE infos (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          subtitle TEXT,
          tags TEXT,
          type TEXT,
          content TEXT,
          is_published INTEGER NOT NULL DEFAULT 0,
          published_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          deleted_at TEXT,
          need_update INTEGER NOT NULL DEFAULT 1,
          is_read INTEGER NOT NULL DEFAULT 0
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

    if (oldVersion < 3) {
      // Add is_locked column to tag_data table
      await db.execute('''
        ALTER TABLE tag_data
        ADD COLUMN is_locked INTEGER DEFAULT 0
      ''');
    }

    if (oldVersion < 4) {
      // Add interaction_mode column to projects table
      await db.execute('''
        ALTER TABLE projects
        ADD COLUMN interaction_mode TEXT
      ''');

      await db.execute('''
        ALTER TABLE polygons
        ADD COLUMN short_code TEXT
      ''');

      await db.execute('''
        ALTER TABLE polygons
        ADD COLUMN long_code TEXT
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN remote_id TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN sls_id TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN sls_short_code TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN sls_long_code TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN sls_name TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN village_id TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN village_short_code TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN village_long_code TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN village_name TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN subdistrict_id TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN subdistrict_short_code TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN subdistrict_long_code TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN subdistrict_name TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN regency_id TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN regency_short_code TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN regency_long_code TEXT;
      ''');

      await db.execute('''
        ALTER TABLE tag_data ADD COLUMN regency_name TEXT;
      ''');

      await db.execute('''
        ALTER TABLE projects 
        ADD COLUMN remote_id TEXT;
      ''');

      // 14. Create sls_with_business table
      await db.execute('''
        CREATE TABLE sls_with_business (
          id TEXT PRIMARY KEY,
          sls_id TEXT,
          sls_short_code TEXT,
          sls_long_code TEXT,
          sls_name TEXT,
          village_id TEXT,
          village_short_code TEXT,
          village_long_code TEXT,
          village_name TEXT,
          subdistrict_id TEXT,
          subdistrict_short_code TEXT,
          subdistrict_long_code TEXT,
          subdistrict_name TEXT,
          regency_id TEXT,
          regency_short_code TEXT,
          regency_long_code TEXT,
          regency_name TEXT,

          business_count INTEGER DEFAULT 0,

          user_id TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE user_polygons (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          polygon_id TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id),
          FOREIGN KEY(polygon_id) REFERENCES polygons(id)
        )
      ''');
    }

    if (oldVersion < 5) {
      // 16. Create families table
      await db.execute('''
        CREATE TABLE families (
          id TEXT PRIMARY KEY,
          name TEXT,
          address TEXT,
          created_at TEXT
        )
      ''');

      // 17. Create family_photos table
      await db.execute('''
        CREATE TABLE family_photos (
          id TEXT PRIMARY KEY,
          family_id TEXT,
          type TEXT,
          filename TEXT,
          FOREIGN KEY(family_id) REFERENCES families(id)
        )
       ''');

      // 18. Create infos table
      await db.execute('''
        CREATE TABLE infos (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          subtitle TEXT,
          tags TEXT,
          type TEXT,
          content TEXT,
          is_published INTEGER NOT NULL DEFAULT 0,
          published_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          deleted_at TEXT,
          need_update INTEGER NOT NULL DEFAULT 1,
          is_read INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 6) {
      await db.execute('''
      ALTER TABLE tag_data
      ADD COLUMN id_sbr TEXT
    ''');

      await db.execute('''
      ALTER TABLE tag_data
      ADD COLUMN original_area TEXT
    ''');
    }
  }
}
