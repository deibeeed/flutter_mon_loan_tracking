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
          .map((e) => e as String)
          .toList(),
      id: json['id'] as String? ?? Constants.NO_ID,
      perSquareMeterRate: json['perSquareMeterRate'] as num,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'loanInterestRate': instance.loanInterestRate,
      'incidentalFeeRate': instance.incidentalFeeRate,
      'reservationFee': instance.reservationFee,
      'perSquareMeterRate': instance.perSquareMeterRate,
      'lotCategories': instance.lotCategories,
      'id': instance.id,
    };
