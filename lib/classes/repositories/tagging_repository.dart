import 'package:kendedes_mobile/classes/providers/tagging_provider.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class TaggingRepository {
  static final TaggingRepository _instance = TaggingRepository._internal();
  factory TaggingRepository() => _instance;

  TaggingRepository._internal();

  late TaggingProvider _taggingProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _taggingProvider = TaggingProvider();
    await _taggingProvider.init();
  }

  Future<List<TagData>> getTaggingInBox({
    required double minLat,
    required double minLng,
    required double maxLat,
    required double maxLng,
  }) async {
    final response = await _taggingProvider.getTaggingInBox(
      minLat,
      minLng,
      maxLat,
      maxLng,
    );
    return response.map((data) => TagData.fromJson(data)).toList();
  }

  Future<TagData> storeTagging(TagData tagData) async {
    final response = await _taggingProvider.storeTagging(tagData.toJson());
    return TagData.fromJson(response);
  }

  Future<TagData> updateTagging(TagData tagData) async {
    final response = await _taggingProvider.updateTagging(
      tagData.id,
      tagData.toJson(),
    );
    return TagData.fromJson(response);
  }

  Future<void> deleteTagging(String taggingId) async {
    await _taggingProvider.deleteTagging(taggingId);
  }

  Future<bool> deleteMultipleTags(List<String> ids) async {
    final response = await _taggingProvider.deleteMultipleTags(ids);
    return response['success'];
  }

  Future<List<String>> uploadMultipleTags(List<TagData> tags) async {
    final List<Map<String, dynamic>> tagJsonList =
        tags.map((tag) => tag.toJson()).toList();
    final response = await _taggingProvider.uploadMultipleTags(tagJsonList);
    return List<String>.from(response['uploaded_ids']);
  }
}
