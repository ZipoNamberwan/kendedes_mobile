import 'package:kendedes_mobile/classes/providers/local_db/organization_db_provider.dart';
import 'package:kendedes_mobile/models/organization.dart';

class OrganizationDbRepository {
  static final OrganizationDbRepository _instance =
      OrganizationDbRepository._internal();
  factory OrganizationDbRepository() => _instance;

  OrganizationDbRepository._internal();

  late OrganizationDbProvider _provider;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _provider = OrganizationDbProvider();
    await _provider.init();
  }

  Future<void> insert(Organization org) async {
    final map = {
      'id': org.id,
      'short_code': org.shortCode,
      'long_code': org.longCode,
      'name': org.name,
    };
    await _provider.insert(map);
  }

  Future<Organization?> getById(String id) async {
    final map = await _provider.getById(id);
    if (map == null) return null;

    return Organization(
      id: map['id'],
      shortCode: map['short_code'],
      longCode: map['long_code'],
      name: map['name'],
    );
  }

  Future<List<Organization>> getAll() async {
    final maps = await _provider.getAll();
    return maps
        .map(
          (map) => Organization(
            id: map['id'],
            shortCode: map['short_code'],
            longCode: map['long_code'],
            name: map['name'],
          ),
        )
        .toList();
  }
}
