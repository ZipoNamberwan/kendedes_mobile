import 'package:kendedes_mobile/classes/providers/util/kbli_provider.dart';
import 'package:kendedes_mobile/models/kbli.dart';

class KbliRepository {
  static final KbliRepository _instance = KbliRepository._internal();
  factory KbliRepository() => _instance;

  KbliRepository._internal();

  late KbliProvider _kbliProvider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _kbliProvider = KbliProvider();
    await _kbliProvider.init();
  }

  Future<List<Kbli>> getKbliStatistics({
    required String type,
    required String longCode,
  }) async {
    final response = await _kbliProvider.getKbliStatistics(type, longCode);
    return response.map((data) => Kbli.fromJson(data)).toList();
  }
}
