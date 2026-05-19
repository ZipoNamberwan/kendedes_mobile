class Family {
  final String name;
  final String address;
  final List<FamilyPhoto> photos;

  const Family({
    required this.name,
    required this.address,
    required this.photos,
  });

  FamilyPhoto? getPhoto(PhotoType type) {
    try {
      return photos.firstWhere((e) => e.type.key == type.key);
    } catch (_) {
      return null;
    }
  }
}

class FamilyPhoto {
  final PhotoType type;
  final String url;

  const FamilyPhoto({required this.type, required this.url});
}

class PhotoType {
  final String key;
  final String label;

  const PhotoType({required this.key, required this.label});

  static const front = PhotoType(key: 'front', label: 'Tampak Depan');

  static const main = PhotoType(key: 'main', label: 'Ruang Tamu');

  static const values = [front, main];
}
