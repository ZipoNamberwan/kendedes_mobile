// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class TagDataAdapter extends TypeAdapter<TagData> {
  @override
  final typeId = 0;

  @override
  TagData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TagData(
      id: fields[0] as String,
      positionLat: (fields[1] as num).toDouble(),
      positionLng: (fields[2] as num).toDouble(),
      hasChanged: fields[3] as bool,
      hasSentToServer: fields[4] as bool,
      type: fields[5] as TagType,
      initialPositionLat: (fields[6] as num).toDouble(),
      initialPositionLng: (fields[7] as num).toDouble(),
      isDeleted: fields[8] as bool,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
      deletedAt: fields[11] as DateTime?,
      incrementalId: (fields[12] as num?)?.toInt(),
      project: fields[13] as Project,
      businessName: fields[14] as String,
      businessOwner: fields[15] as String?,
      businessAddress: fields[16] as String?,
      buildingStatus: fields[17] as BuildingStatus,
      description: fields[18] as String,
      sector: fields[19] as Sector,
      note: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TagData obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.positionLat)
      ..writeByte(2)
      ..write(obj.positionLng)
      ..writeByte(3)
      ..write(obj.hasChanged)
      ..writeByte(4)
      ..write(obj.hasSentToServer)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.initialPositionLat)
      ..writeByte(7)
      ..write(obj.initialPositionLng)
      ..writeByte(8)
      ..write(obj.isDeleted)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.deletedAt)
      ..writeByte(12)
      ..write(obj.incrementalId)
      ..writeByte(13)
      ..write(obj.project)
      ..writeByte(14)
      ..write(obj.businessName)
      ..writeByte(15)
      ..write(obj.businessOwner)
      ..writeByte(16)
      ..write(obj.businessAddress)
      ..writeByte(17)
      ..write(obj.buildingStatus)
      ..writeByte(18)
      ..write(obj.description)
      ..writeByte(19)
      ..write(obj.sector)
      ..writeByte(20)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final typeId = 1;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      deletedAt: fields[5] as DateTime?,
      type: fields[6] as ProjectType,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.deletedAt)
      ..writeByte(6)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SectorAdapter extends TypeAdapter<Sector> {
  @override
  final typeId = 2;

  @override
  Sector read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sector(key: fields[0] as String, text: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, Sector obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuildingStatusAdapter extends TypeAdapter<BuildingStatus> {
  @override
  final typeId = 3;

  @override
  BuildingStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingStatus(key: fields[0] as String, text: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, BuildingStatus obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectTypeAdapter extends TypeAdapter<ProjectType> {
  @override
  final typeId = 4;

  @override
  ProjectType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectType(key: fields[0] as String, text: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, ProjectType obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TagTypeAdapter extends TypeAdapter<TagType> {
  @override
  final typeId = 5;

  @override
  TagType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TagType.auto;
      case 1:
        return TagType.manual;
      case 2:
        return TagType.move;
      default:
        return TagType.auto;
    }
  }

  @override
  void write(BinaryWriter writer, TagType obj) {
    switch (obj) {
      case TagType.auto:
        writer.writeByte(0);
      case TagType.manual:
        writer.writeByte(1);
      case TagType.move:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
