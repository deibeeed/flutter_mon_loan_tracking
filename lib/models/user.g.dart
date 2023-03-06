// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      birthDate: json['birthDate'] as String,
      civilStatus: $enumDecode(_$CivilStatusEnumMap, json['civilStatus']),
      mobileNumber: json['mobileNumber'] as String,
      id: json['id'] as String? ?? Constants.NO_ID,
      type: $enumDecodeNullable(_$UserTypeEnumMap, json['type']) ??
          UserType.customer,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'birthDate': instance.birthDate,
      'civilStatus': _$CivilStatusEnumMap[instance.civilStatus]!,
      'mobileNumber': instance.mobileNumber,
      'id': instance.id,
      'type': _$UserTypeEnumMap[instance.type]!,
    };

const _$CivilStatusEnumMap = {
  CivilStatus.single: 'single',
  CivilStatus.married: 'married',
  CivilStatus.divorced: 'divorced',
};

const _$UserTypeEnumMap = {
  UserType.customer: 'customer',
  UserType.admin: 'admin',
  UserType.agent: 'agent',
  UserType.accountant: 'accountant',
  UserType.subAdmin: 'subAdmin',
};
