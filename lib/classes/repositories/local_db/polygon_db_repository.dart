import 'package:kendedes_mobile/classes/providers/local_db/polygon_db_provider.dart';
import 'package:kendedes_mobile/models/polygon.dart';

class PolygonDbRepository {
  static final PolygonDbRepository _instance = PolygonDbRepository._internal();
  factory PolygonDbRepository() => _instance;

  PolygonDbRepository._internal();

  late PolygonDbProvider _provider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = PolygonDbProvider();
    await _provider.init();
  }

  /// Save polygon with its points using the Polygon model
  Future<void> savePolygonWithPoints(Polygon polygon) async {
    await _provider.savePolygonWithPoints(
      polygon.toDbMap(),
      polygon.pointsToDbList(),
    );
  }

  /// Add a relationship between a polygon and a project
  Future<void> addProjectPolygonPair(String projectId, String polygonId) async {
    await _provider.addProjectPolygonPair(projectId, polygonId);
  }

  /// Remove a relationship between a polygon and a project
  Future<void> removeProjectPolygonPair(
    String projectId,
    String polygonId,
  ) async {
    await _provider.removeProjectPolygonPair(projectId, polygonId);
  }

  /// Get all polygons associated with a project
  Future<List<Polygon>> getPolygonsForProject(String projectId) async {
    // Get polygon IDs for the project
    final polygonIds = await _provider.getPolygonsForProject(projectId);

    // Get full polygon data for each ID
    final List<Polygon> polygons = [];
    for (String polygonId in polygonIds) {
      final polygon = await getPolygonById(polygonId);
      if (polygon != null) {
        polygons.add(polygon);
      }
    }

    return polygons;
  }

  /// Get a polygon by its ID
  Future<Polygon?> getPolygonById(String polygonId) async {
    final polygonWithPoints = await _provider.getPolygonWithPointsById(
      polygonId,
    );

    if (polygonWithPoints == null) {
      return null;
    }

    final polygonData = polygonWithPoints['polygon'] as Map<String, dynamic>;
    final pointsData =
        polygonWithPoints['points'] as List<Map<String, dynamic>>;

    return Polygon.fromDbData(polygonData, pointsData);
  }
}
