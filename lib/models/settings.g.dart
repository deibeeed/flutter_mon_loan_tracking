// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      loanInterestRate: json['loanInterestRate'] as num,
      incidentalFeeRate: json['incidentalFeeRate'] as num,
      serviceFee: json['serviceFee'] as num? ?? 30000,
      lotCategories: (json['lotCategories'] as List<dynamic>)
          .map((e) => LotCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String? ?? Constants.NO_ID,
      createdAt: json['createdAt'] as num? ?? Constants.NO_DATE,
      downPaymentRate: json['downPaymentRate'] as num? ?? 20,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'loanInterestRate': instance.loanInterestRate,
      'incidentalFeeRate': instance.incidentalFeeRate,
      'serviceFee': instance.serviceFee,
      'lotCategories': instance.lotCategories.map((e) => e.toJson()).toList(),
      'id': instance.id,
      'createdAt': instance.createdAt,
      'downPaymentRate': instance.downPaymentRate,
    };
