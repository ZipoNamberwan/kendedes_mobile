import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class PhotoDbProvider {
  static final PhotoDbProvider _instance = PhotoDbProvider._internal();
  factory PhotoDbProvider() => _instance;

  PhotoDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  Database get _db => _dbProvider.db;

  // ==================== FAMILY CRUD ====================

  /// Create a new family
  Future<int> insertFamily(Map<String, dynamic> family) async {
    return await _db.insert(
      'families',
      family,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a single family by id
  Future<Map<String, dynamic>?> getFamily(String id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'families',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Get all families
  Future<List<Map<String, dynamic>>> getAllFamilies() async {
    return await _db.query('families');
  }

  /// Update a family
  Future<int> updateFamily(Map<String, dynamic> family) async {
    return await _db.update(
      'families',
      family,
      where: 'id = ?',
      whereArgs: [family['id']],
    );
  }

  /// Delete a family
  Future<int> deleteFamily(String id) async {
    // Delete associated photos first
    await deleteFamilyPhotosByFamilyId(id);

    return await _db.delete('families', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== FAMILY PHOTO CRUD ====================

  /// Create a new family photo
  Future<int> insertFamilyPhoto(Map<String, dynamic> photo) async {
    return await _db.insert(
      'family_photos',
      photo,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a single family photo by id
  Future<Map<String, dynamic>?> getFamilyPhoto(String id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'family_photos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Get all photos for a specific family
  Future<List<Map<String, dynamic>>> getFamilyPhotosByFamilyId(
    String familyId,
  ) async {
    return await _db.query(
      'family_photos',
      where: 'family_id = ?',
      whereArgs: [familyId],
    );
  }

  /// Get all family photos
  Future<List<Map<String, dynamic>>> getAllFamilyPhotos() async {
    return await _db.query('family_photos');
  }

  /// Update a family photo
  Future<int> updateFamilyPhoto(Map<String, dynamic> photo) async {
    return await _db.update(
      'family_photos',
      photo,
      where: 'id = ?',
      whereArgs: [photo['id']],
    );
  }

  /// Delete a family photo
  Future<int> deleteFamilyPhoto(String id) async {
    return await _db.delete('family_photos', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all photos for a specific family
  Future<int> deleteFamilyPhotosByFamilyId(String familyId) async {
    return await _db.delete(
      'family_photos',
      where: 'family_id = ?',
      whereArgs: [familyId],
    );
  }

  /// Get family with photos (returns map with family data and photos list)
  Future<Map<String, dynamic>?> getFamilyWithPhotos(String familyId) async {
    final family = await getFamily(familyId);
    if (family == null) return null;

    final photos = await getFamilyPhotosByFamilyId(familyId);

    return {'family': family, 'photos': photos};
  }

  /// Get all families with their photos
  Future<List<Map<String, dynamic>>> getAllFamiliesWithPhotos() async {
    final families = await getAllFamilies();
    final result = <Map<String, dynamic>>[];

    for (var family in families) {
      final photos = await getFamilyPhotosByFamilyId(family['id'] as String);
      result.add({'family': family, 'photos': photos});
    }

    return result;
  }
}
