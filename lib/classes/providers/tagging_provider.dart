import 'package:kendedes_mobile/classes/services/dio_service.dart';

class TaggingProvider {
  static final TaggingProvider _instance = TaggingProvider._internal();
  factory TaggingProvider() => _instance;

  TaggingProvider._internal();

  late DioService _dioService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _dioService = DioService();
    await _dioService.init();
  }

  Future<List<Map<String, dynamic>>> getTaggingInBox(
    double minLat,
    double minLng,
    double maxLat,
    double maxLng,
  ) async {
    final response = await _dioService.dio.get(
      '/business-in-box',
      queryParameters: {
        'min_lat': minLat,
        'min_lng': minLng,
        'max_lat': maxLat,
        'max_lng': maxLng,
      },
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> storeTagging(
    Map<String, dynamic> taggingData,
  ) async {
    final response = await _dioService.dio.post('/business', data: taggingData);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateTagging(
    String taggingId,
    Map<String, dynamic> taggingData,
  ) async {
    final response = await _dioService.dio.put(
      '/business/$taggingId',
      data: taggingData,
    );
    return response.data['data'];
  }

  Future<void> deleteTagging(String taggingId) async {
    await _dioService.dio.delete('/business/$taggingId');
  }

  Future<Map<String, dynamic>> deleteMultipleTags(List<String> ids) async {
    final response = await _dioService.dio.delete(
      '/business/delete-multiple',
      data: {'ids': ids},
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> uploadMultipleTags(
    List<Map<String, dynamic>> taggingData,
  ) async {
    final response = await _dioService.dio.post(
      '/business/upload-multiple',
      data: {'tags': taggingData},
    );
    return response.data['data'];
  }
}
