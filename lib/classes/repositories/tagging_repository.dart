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

  Future<TagData> storeTagging(TagData taggingData) async {
    final response = await _taggingProvider.storeTagging(taggingData.toJson());
    return TagData.fromJson(response);
  }

  Future<TagData> updateTagging(String taggingId, TagData taggingData) async {
    final response = await _taggingProvider.updateTagging(
      taggingId,
      taggingData.toJson(),
    );
    return TagData.fromJson(response);
  }

  Future<void> deleteTagging(String taggingId) async {
    await _taggingProvider.deleteTagging(taggingId);
  }
}
