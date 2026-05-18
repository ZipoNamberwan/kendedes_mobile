class Photo {
  final String id;
  final String name;
  final String? area;
  final String? note;
  final String photoUrl;

  Photo({
    required this.id,
    required this.name,
    this.area,
    this.note,
    required this.photoUrl,
  });
}
