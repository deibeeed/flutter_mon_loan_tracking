// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employment_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmploymentDetails _$EmploymentDetailsFromJson(Map<String, dynamic> json) =>
    EmploymentDetails(
      companyName: json['companyName'] as String,
      natureOfBusiness: json['natureOfBusiness'] as String,
      address: json['address'] as String,
      position: json['position'] as String,
      years: json['years'] as num,
      id: json['id'] as String? ?? Constants.NO_ID,
    );

Map<String, dynamic> _$EmploymentDetailsToJson(EmploymentDetails instance) =>
    <String, dynamic>{
      'companyName': instance.companyName,
      'natureOfBusiness': instance.natureOfBusiness,
      'address': instance.address,
      'position': instance.position,
      'years': instance.years,
      'id': instance.id,
    };
