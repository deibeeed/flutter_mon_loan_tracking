// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      loanInterestRate: json['loanInterestRate'] as num,
      incidentalFeeRate: json['incidentalFeeRate'] as num,
      reservationFee: json['reservationFee'] as num,
      lotCategories: (json['lotCategories'] as List<dynamic>)
          .map((e) => LotCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String? ?? Constants.NO_ID,
      createdAt: json['createdAt'] as num? ?? Constants.NO_DATE,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'loanInterestRate': instance.loanInterestRate,
      'incidentalFeeRate': instance.incidentalFeeRate,
      'reservationFee': instance.reservationFee,
      'lotCategories': instance.lotCategories,
      'id': instance.id,
      'createdAt': instance.createdAt,
    };
