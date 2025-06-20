import 'package:kendedes_mobile/classes/providers/local_database_provider.dart';

class LocalDatabaseRepository {
  static final LocalDatabaseRepository _instance = LocalDatabaseRepository._internal();
  factory LocalDatabaseRepository() => _instance;

  LocalDatabaseRepository._internal();

  late LocalDatabaseProvider _provider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = LocalDatabaseProvider();
    await _provider.init();
  }
}
