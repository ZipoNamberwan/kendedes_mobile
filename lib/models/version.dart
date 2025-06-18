class Version {
  final String title;
  final String? description;
  final int versionCode;
  final String? url;
  final bool isMandatory;

  Version({
    required this.title,
    this.description,
    required this.versionCode,
    this.url,
    required this.isMandatory,
  });

  //make fromJson method
  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      title: json['title'] as String,
      description: json['description'] as String?,
      versionCode: json['version_code'] as int,
      url: json['url'] as String?,
      isMandatory: json['is_mandatory'] == 1,
    );
  }

  //make toJson method
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'version_code': versionCode,
      'url': url,
      'is_mandatory': isMandatory ? 1 : 0,
    };
  }
}
