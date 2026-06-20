import 'package:kendedes_mobile/classes/providers/util/info_provider.dart';
import 'package:kendedes_mobile/models/info_util/Info.dart';

class InfoRepository {
  static final InfoRepository _instance = InfoRepository._internal();
  factory InfoRepository() => _instance;

  InfoRepository._internal();

  late InfoProvider _infoProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _infoProvider = InfoProvider();
    await _infoProvider.init();
  }

  /// Fetches a list of [Info] objects from the server.
  /// [lastCheck] is an optional date string sent as the [last_check] query param.
  /// Returns an empty list if the server returns no data.
  Future<List<Info>> getInfoList({String? lastCheck}) async {
    final rawList = await _infoProvider.getInfoList(lastCheck: lastCheck);
    if (rawList == null) return [];
    return rawList.map((data) => Info.fromServerJson(data)).toList();
  }

  /// Fetches the full detail of a single [Info] by [id].
  /// Returns null if the server returns no data for the given id.
  Future<Info?> getInfoDetail(String id) async {
    final rawMap = await _infoProvider.getInfoDetail(id);
    if (rawMap == null) return null;
    return Info.fromServerJson(rawMap);
  }
}

