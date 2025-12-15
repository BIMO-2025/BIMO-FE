// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_timeline_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalTimelineEventAdapter extends TypeAdapter<LocalTimelineEvent> {
  @override
  final int typeId = 0;

  @override
  LocalTimelineEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalTimelineEvent(
      id: fields[0] as String,
      flightId: fields[1] as String,
      order: fields[2] as int,
      type: fields[3] as String,
      title: fields[4] as String,
      description: fields[5] as String,
      startTime: fields[6] as DateTime,
      endTime: fields[7] as DateTime,
      iconType: fields[8] as String?,
      isEditable: fields[9] as bool,
      isCustom: fields[10] as bool,
      isActive: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalTimelineEvent obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.flightId)
      ..writeByte(2)
      ..write(obj.order)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.startTime)
      ..writeByte(7)
      ..write(obj.endTime)
      ..writeByte(8)
      ..write(obj.iconType)
      ..writeByte(9)
      ..write(obj.isEditable)
      ..writeByte(10)
      ..write(obj.isCustom)
      ..writeByte(11)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalTimelineEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
