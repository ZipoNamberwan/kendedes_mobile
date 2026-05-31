class Kbli {
  final String id;
  final String? category;
  final String? code;
  final String? description;
  final int count;

  Kbli({
    required this.id,
    required this.category,
    required this.code,
    required this.description,
    required this.count,
  });

  factory Kbli.fromJson(Map<String, dynamic> json) => Kbli(
    id: json['id']?.toString() ?? '',
    category: json['category'] ?? '',
    code: json['code'] ?? '',
    description: json['description'] ?? '',
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
}
