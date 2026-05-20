class Family {
  final String id;
  final String name;
  final String address;
  final DateTime createdAt;
  final List<FamilyPhoto> photos;

  const Family({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
    required this.photos,
  });

  FamilyPhoto? getPhoto(PhotoType type) {
    try {
      return photos.firstWhere((e) => e.type.key == type.key);
    } catch (_) {
      return null;
    }
  }

  // Convert Family to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Family from Map (without photos)
  factory Family.fromMap(
    Map<String, dynamic> map, {
    List<FamilyPhoto>? photos,
  }) {
    return Family(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      photos: photos ?? [],
    );
  }
}

class FamilyPhoto {
  final String id;
  final PhotoType type;
  final String filename;

  const FamilyPhoto({
    required this.id,
    required this.type,
    required this.filename,
  });

  // Convert FamilyPhoto to Map for database
  Map<String, dynamic> toMap(String familyId) {
    return {
      'id': id,
      'family_id': familyId,
      'type': type.key,
      'filename': filename,
    };
  }

  // Create FamilyPhoto from Map
  factory FamilyPhoto.fromMap(Map<String, dynamic> map) {
    return FamilyPhoto(
      id: map['id'] as String,
      type: PhotoType.values.firstWhere(
        (e) => e.key == map['type'],
        orElse: () => PhotoType.front,
      ),
      filename: map['filename'] as String,
    );
  }
}

class PhotoType {
  final String key;
  final String label;

  const PhotoType({required this.key, required this.label});

  static const front = PhotoType(key: 'front', label: 'Tampak Depan');

  static const main = PhotoType(key: 'main', label: 'Ruang Tamu');

  static const values = [front, main];
}
