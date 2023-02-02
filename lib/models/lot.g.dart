// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lot _$LotFromJson(Map<String, dynamic> json) => Lot(
      lotCategory: json['lotCategory'] as String,
      totalContractPrice: json['totalContractPrice'] as num,
      blockNo: json['blockNo'] as String,
      lotNo: json['lotNo'] as String,
      area: json['area'] as num,
      description: json['description'] as String,
      id: json['id'] as String? ?? Constants.NO_ID,
      clientId: json['clientId'] as String?,
      updatedAt: json['updatedAt'] as num? ?? Constants.NO_DATE,
      createdAt: json['createdAt'] as num,
    );

Map<String, dynamic> _$LotToJson(Lot instance) => <String, dynamic>{
      'lotCategory': instance.lotCategory,
      'totalContractPrice': instance.totalContractPrice,
      'blockNo': instance.blockNo,
      'lotNo': instance.lotNo,
      'description': instance.description,
      'id': instance.id,
      'clientId': instance.clientId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'area': instance.area,
    };
