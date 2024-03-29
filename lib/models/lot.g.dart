// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lot _$LotFromJson(Map<String, dynamic> json) => Lot(
      lotCategoryKey: json['lotCategoryKey'] as String,
      blockNo: json['blockNo'] as String,
      lotNo: json['lotNo'] as String,
      area: json['area'] as num,
      description: json['description'] as String,
      id: json['id'] as String? ?? Constants.NO_ID,
      updatedAt: json['updatedAt'] as num? ?? Constants.NO_DATE,
      createdAt: json['createdAt'] as num,
      reservedTo: json['reservedTo'] as String?,
    );

Map<String, dynamic> _$LotToJson(Lot instance) => <String, dynamic>{
      'lotCategoryKey': instance.lotCategoryKey,
      'blockNo': instance.blockNo,
      'lotNo': instance.lotNo,
      'description': instance.description,
      'id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'area': instance.area,
      'reservedTo': instance.reservedTo,
    };
