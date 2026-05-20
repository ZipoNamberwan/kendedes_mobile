import 'package:kendedes_mobile/classes/providers/local_db/photo_db_provider.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';

class PhotoDbRepository {
  static final PhotoDbRepository _instance = PhotoDbRepository._internal();
  factory PhotoDbRepository() => _instance;

  PhotoDbRepository._internal();

  late PhotoDbProvider _photoDbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _photoDbProvider = PhotoDbProvider();
    await _photoDbProvider.init();
  }

  /// Create a new family with its photos
  Future<int> insertFamily(Family family) async {
    // Insert family
    final familyResult = await _photoDbProvider.insertFamily(family.toMap());

    // Insert photos
    for (var photo in family.photos) {
      await _photoDbProvider.insertFamilyPhoto(photo.toMap(family.id));
    }

    return familyResult;
  }

  /// Get a single family by id with its photos
  Future<Family?> getFamily(String id) async {
    final familyMap = await _photoDbProvider.getFamily(id);
    if (familyMap == null) return null;

    final photoMaps = await _photoDbProvider.getFamilyPhotosByFamilyId(id);
    final photos = photoMaps.map((map) => FamilyPhoto.fromMap(map)).toList();

    return Family.fromMap(familyMap, photos: photos);
  }

  /// Get all families with their photos
  Future<List<Family>> getAllFamilies() async {
    final familyMaps = await _photoDbProvider.getAllFamilies();
    final families = <Family>[];

    for (var familyMap in familyMaps) {
      final id = familyMap['id'] as String;
      final photoMaps = await _photoDbProvider.getFamilyPhotosByFamilyId(id);
      final photos = photoMaps.map((map) => FamilyPhoto.fromMap(map)).toList();

      families.add(Family.fromMap(familyMap, photos: photos));
    }

    // Sort by createdAt descending (newest first)
    families.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return families;
  }

  /// Delete a family and its photos
  Future<int> deleteFamily(String id) async {
    return await _photoDbProvider.deleteFamily(id);
  }
}
