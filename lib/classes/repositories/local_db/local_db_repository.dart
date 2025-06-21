import 'package:kendedes_mobile/classes/providers/local_db/local_db_provider.dart';

class LocalDbRepository {
  static final LocalDbRepository _instance = LocalDbRepository._internal();
  factory LocalDbRepository() => _instance;

  LocalDbRepository._internal();

  late LocalDbProvider _provider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = LocalDbProvider();
    await _provider.init();
  }
}
