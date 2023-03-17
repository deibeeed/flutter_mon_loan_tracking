// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      houseNo: json['houseNo'] as String,
      street: json['street'] as String,
      brgy: json['brgy'] as String,
      zone: json['zone'] as String,
      city: json['city'] as String,
      province: json['province'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
      userId: json['userId'] as String,
      id: json['id'] as String? ?? Constants.NO_ID,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'houseNo': instance.houseNo,
      'street': instance.street,
      'brgy': instance.brgy,
      'zone': instance.zone,
      'city': instance.city,
      'province': instance.province,
      'zipCode': instance.zipCode,
      'country': instance.country,
      'userId': instance.userId,
      'id': instance.id,
    };
