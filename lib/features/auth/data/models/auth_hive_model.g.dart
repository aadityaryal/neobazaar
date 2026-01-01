// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthHiveModelAdapter extends TypeAdapter<AuthHiveModel> {
  @override
  final int typeId = 0;

  @override
  AuthHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthHiveModel(
      userId: fields[0] as String?,
      fullName: fields[1] as String,
      email: fields[2] as String,
      phoneNumber: fields[3] as String?,
      username: fields[4] as String,
      password: fields[5] as String?,
      neoTokens: fields[6] as int?,
      xp: fields[7] as int?,
      reputationScore: fields[8] as int?,
      kycVerified: fields[9] as bool?,
      badges: (fields[10] as List?)?.cast<String>(),
      location: fields[11] as String?,
      profileImage: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.authId)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.password)
      ..writeByte(6)
      ..write(obj.neoTokens)
      ..writeByte(7)
      ..write(obj.xp)
      ..writeByte(8)
      ..write(obj.reputationScore)
      ..writeByte(9)
      ..write(obj.kycVerified)
      ..writeByte(10)
      ..write(obj.badges)
      ..writeByte(11)
      ..write(obj.location)
      ..writeByte(12)
      ..write(obj.profileImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
