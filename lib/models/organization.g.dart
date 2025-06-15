// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrganizationAdapter extends TypeAdapter<Organization> {
  @override
  final typeId = 7;

  @override
  Organization read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Organization(
      id: fields[0] as String,
      name: fields[3] as String,
      shortCode: fields[1] as String,
      longCode: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Organization obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.shortCode)
      ..writeByte(2)
      ..write(obj.longCode)
      ..writeByte(3)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
