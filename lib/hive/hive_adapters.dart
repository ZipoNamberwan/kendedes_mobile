import 'package:hive_ce/hive.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<TagData>(),
  AdapterSpec<Project>(),
  AdapterSpec<Sector>(),
  AdapterSpec<BuildingStatus>(),
  AdapterSpec<ProjectType>(),
  AdapterSpec<TagType>(),
])

class HiveAdapters {}