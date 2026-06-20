import 'package:kendedes_mobile/classes/providers/util/info_db_provider.dart';
import 'package:kendedes_mobile/models/info_util/Info.dart';

class InfoDbRepository {
  static final InfoDbRepository _instance = InfoDbRepository._internal();
  factory InfoDbRepository() => _instance;

  InfoDbRepository._internal();

  late InfoDbProvider _infoDbProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _infoDbProvider = InfoDbProvider();
    await _infoDbProvider.init();
  }

  // ==================== INFOS ====================

  /// Saves a list of [Info] objects to the local database.
  /// Each [Info] is serialized via [toJson] before being stored.
  /// Returns the number of rows written.
  Future<int> saveInfoList(List<Info> infoList) async {
    final maps = infoList.map((info) => info.toJson()).toList();
    return await _infoDbProvider.saveInfoList(maps);
  }

  /// Updates the [needUpdate] flag for the given [id] and returns
  /// the updated [Info] object, or null if no row was found.
  Future<Info?> updateNeedUpdate(String id, {required bool needUpdate}) async {
    await _infoDbProvider.updateNeedUpdate(id, needUpdate: needUpdate);
    final map = await _infoDbProvider.getInfoById(id);
    if (map == null) return null;
    return Info.fromDbJson(map);
  }

  /// Saves [content] for the given [id] and returns the updated
  /// [Info] object, or null if no row was found.
  Future<Info?> saveContent(String id, String content) async {
    await _infoDbProvider.saveContent(id, content);
    final map = await _infoDbProvider.getInfoById(id);
    if (map == null) return null;
    return Info.fromDbJson(map);
  }

  /// Updates the [isRead] flag for the given [id] and returns
  /// the updated [Info] object, or null if no row was found.
  Future<Info?> updateIsRead(String id, {required bool isRead}) async {
    await _infoDbProvider.updateIsRead(id, isRead: isRead);
    final map = await _infoDbProvider.getInfoById(id);
    if (map == null) return null;
    return Info.fromDbJson(map);
  }

  /// Returns all stored [Info] objects.
  Future<List<Info>> getAllInfos() async {
    final maps = await _infoDbProvider.getAllInfos();
    return maps.map((map) => Info.fromDbJson(map)).toList();
  }

  /// Returns a single [Info] by [id], or null if not found.
  Future<Info?> getInfoById(String id) async {
    final map = await _infoDbProvider.getInfoById(id);
    if (map == null) return null;
    return Info.fromDbJson(map);
  }

  // ==================== SHARED PREFERENCES ====================

  /// Persists the last-check timestamp for infos (milliseconds since epoch).
  Future<void> saveLastCheckInfos(int millisecondsSinceEpoch) async {
    await _infoDbProvider.saveLastCheckInfos(millisecondsSinceEpoch);
  }

  /// Returns the last-check timestamp for infos as a [DateTime],
  /// or null if it has never been saved.
  DateTime? getLastCheckInfos() {
    final ms = _infoDbProvider.getLastCheckInfos();
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}

