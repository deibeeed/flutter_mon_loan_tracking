// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beneficiary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Beneficiary _$BeneficiaryFromJson(Map<String, dynamic> json) => Beneficiary(
      name: json['name'] as String,
      birthDate: json['birthDate'] as num,
      relationship: json['relationship'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      id: json['id'] as String? ?? Constants.NO_ID,
      parentId: json['parentId'] as String,
    );

Map<String, dynamic> _$BeneficiaryToJson(Beneficiary instance) =>
    <String, dynamic>{
      'name': instance.name,
      'birthDate': instance.birthDate,
      'relationship': instance.relationship,
      'gender': _$GenderEnumMap[instance.gender]!,
      'id': instance.id,
      'parentId': instance.parentId,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
};
