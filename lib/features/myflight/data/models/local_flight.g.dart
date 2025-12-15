// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_flight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalFlightAdapter extends TypeAdapter<LocalFlight> {
  @override
  final int typeId = 1;

  @override
  LocalFlight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalFlight(
      id: fields[0] as String,
      origin: fields[1] as String,
      destination: fields[2] as String,
      departureTime: fields[3] as DateTime,
      arrivalTime: fields[4] as DateTime,
      totalDuration: fields[5] as String,
      status: fields[6] as String,
      lastModified: fields[7] as DateTime,
      flightGoal: fields[8] as String?,
      seatClass: fields[9] as String?,
      forceInProgress: fields[10] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalFlight obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.origin)
      ..writeByte(2)
      ..write(obj.destination)
      ..writeByte(3)
      ..write(obj.departureTime)
      ..writeByte(4)
      ..write(obj.arrivalTime)
      ..writeByte(5)
      ..write(obj.totalDuration)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.lastModified)
      ..writeByte(8)
      ..write(obj.flightGoal)
      ..writeByte(9)
      ..write(obj.seatClass)
      ..writeByte(10)
      ..write(obj.forceInProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalFlightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
