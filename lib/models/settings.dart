import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/lot_category.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings extends Equatable {
  Settings({
    required this.loanInterestRate,
    required this.incidentalFeeRate,
    required this.serviceFee,
    required this.lotCategories,
    this.id = Constants.NO_ID,
    this.createdAt = Constants.NO_DATE,
    required this.downPaymentRate,
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  factory Settings.updateId({required String id, required Settings settings}) =>
      Settings(
          loanInterestRate: settings.loanInterestRate,
          incidentalFeeRate: settings.incidentalFeeRate,
          serviceFee: settings.serviceFee,
          lotCategories: settings.lotCategories,
          id: id,
          createdAt: settings.createdAt,
          downPaymentRate: settings.downPaymentRate);

  factory Settings.defaultSettings() => Settings(
        loanInterestRate: 7,
        incidentalFeeRate: 10,
        lotCategories: [
          LotCategory(name: 'Corner Lot', ratePerSquareMeter: 9000),
          LotCategory(name: 'Interior Lot', ratePerSquareMeter: 10000),
          LotCategory(name: 'Commercial Lot', ratePerSquareMeter: 11000),
        ],
        serviceFee: 30000,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        downPaymentRate: 20,
      );

  num loanInterestRate;
  num incidentalFeeRate;
  num serviceFee;
  List<LotCategory> lotCategories;
  final String id;
  num createdAt;
  num downPaymentRate;

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  @override
  List<Object?> get props => [
        loanInterestRate,
        incidentalFeeRate,
        serviceFee,
        lotCategories,
        id,
        createdAt,
        downPaymentRate,
      ];
}
