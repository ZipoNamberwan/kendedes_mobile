import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class PolygonDbProvider {
  static final PolygonDbProvider _instance = PolygonDbProvider._internal();
  factory PolygonDbProvider() => _instance;

  PolygonDbProvider._internal();

  late LocalDbProvider _dbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dbProvider = LocalDbProvider();
    await _dbProvider.init();
  }

  /// Save complete polygon with its points in a single transaction
  /// [polygonData] Map containing polygon information
  /// [points] List of Maps containing point coordinates
  Future<void> savePolygonWithPoints(
    Map<String, dynamic> polygonData,
    List<Map<String, dynamic>> points,
  ) async {
    final Database db = _dbProvider.db;

    await db.transaction((txn) async {
      // Save polygon
      await txn.insert(
        'polygons',
        polygonData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Delete existing points for this polygon
      await txn.delete(
        'polygon_points',
        where: 'polygon_id = ?',
        whereArgs: [polygonData['id']],
      );

      // Insert new points
      for (Map<String, dynamic> point in points) {
        final pointData = Map<String, dynamic>.from(point);
        pointData['polygon_id'] = polygonData['id'];

        await txn.insert(
          'polygon_points',
          pointData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Add a relationship between a polygon and a project
  /// [projectId] The ID of the project
  /// [polygonId] The ID of the polygon
  Future<void> addProjectPolygonPair(String projectId, String polygonId) async {
    final Database db = _dbProvider.db;

    await db.insert(
      'project_polygons',
      {'project_id': projectId, 'polygon_id': polygonId},
      conflictAlgorithm:
          ConflictAlgorithm.ignore, // Ignore if relationship already exists
    );
  }

  /// Remove a relationship between a polygon and a project
  /// [projectId] The ID of the project
  /// [polygonId] The ID of the polygon
  Future<void> removeProjectPolygonPair(
    String projectId,
    String polygonId,
  ) async {
    final Database db = _dbProvider.db;

    await db.delete(
      'project_polygons',
      where: 'project_id = ? AND polygon_id = ?',
      whereArgs: [projectId, polygonId],
    );
  }

  /// Get all polygons associated with a project
  /// [projectId] The ID of the project
  /// Returns a list of polygon IDs
  Future<List<String>> getPolygonsForProject(String projectId) async {
    final Database db = _dbProvider.db;

    final List<Map<String, dynamic>> result = await db.query(
      'project_polygons',
      columns: ['polygon_id'],
      where: 'project_id = ?',
      whereArgs: [projectId],
    );

    return result.map((row) => row['polygon_id'] as String).toList();
  }

  /// Get polygon data by ID
  /// [polygonId] The ID of the polygon
  /// Returns polygon data map or null if not found
  Future<Map<String, dynamic>?> getPolygonById(String polygonId) async {
    final Database db = _dbProvider.db;
    
    final List<Map<String, dynamic>> result = await db.query(
      'polygons',
      where: 'id = ?',
      whereArgs: [polygonId],
    );
    
    return result.isNotEmpty ? result.first : null;
  }

  /// Get polygon points by polygon ID
  /// [polygonId] The ID of the polygon
  /// Returns list of point data maps
  Future<List<Map<String, dynamic>>> getPolygonPoints(String polygonId) async {
    final Database db = _dbProvider.db;
    
    final List<Map<String, dynamic>> result = await db.query(
      'polygon_points',
      where: 'polygon_id = ?',
      whereArgs: [polygonId],
      orderBy: 'id', // Maintain point order
    );
    
    return result;
  }

  /// Get complete polygon data with points by ID
  /// [polygonId] The ID of the polygon
  /// Returns a map with 'polygon' and 'points' keys, or null if polygon not found
  Future<Map<String, dynamic>?> getPolygonWithPointsById(String polygonId) async {
    final polygonData = await getPolygonById(polygonId);
    if (polygonData == null) {
      return null;
    }
    
    final pointsData = await getPolygonPoints(polygonId);
    
    return {
      'polygon': polygonData,
      'points': pointsData,
    };
  }
}
