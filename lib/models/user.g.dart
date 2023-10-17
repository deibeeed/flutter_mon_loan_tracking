// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String?,
      birthDate: json['birthDate'] as String,
      civilStatus: $enumDecode(_$CivilStatusEnumMap, json['civilStatus']),
      mobileNumber: json['mobileNumber'] as String,
      id: json['id'] as String? ?? Constants.NO_ID,
      type: $enumDecodeNullable(_$UserTypeEnumMap, json['type']) ??
          UserType.customer,
      middleName: json['middleName'] as String?,
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      birthPlace: json['birthPlace'] as String?,
      nationality: json['nationality'] as String?,
      height: User._heightFromJson(json['height']),
      weight: json['weight'] as num?,
      childrenCount: json['childrenCount'] as num?,
      tinNo: json['tinNo'] as String?,
      sssNo: json['sssNo'] as String?,
      philHealthNo: json['philHealthNo'] as String?,
      spouseId: json['spouseId'] as String?,
      telNo: json['telNo'] as String?,
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
      'spouseId': instance.spouseId,
      'middleName': instance.middleName,
      'gender': _$GenderEnumMap[instance.gender],
      'birthPlace': instance.birthPlace,
      'nationality': instance.nationality,
      'height': instance.height,
      'weight': instance.weight,
      'childrenCount': instance.childrenCount,
      'tinNo': instance.tinNo,
      'sssNo': instance.sssNo,
      'philHealthNo': instance.philHealthNo,
      'telNo': instance.telNo,
    };

const _$CivilStatusEnumMap = {
  CivilStatus.single: 'single',
  CivilStatus.married: 'married',
  CivilStatus.divorced: 'divorced',
  CivilStatus.widow: 'widow',
  CivilStatus.widower: 'widower',
  CivilStatus.annulled: 'annulled',
  CivilStatus.separated: 'separated',
};

const _$UserTypeEnumMap = {
  UserType.customer: 'customer',
  UserType.admin: 'admin',
  UserType.accountant: 'accountant',
  UserType.subAdmin: 'subAdmin',
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
};
