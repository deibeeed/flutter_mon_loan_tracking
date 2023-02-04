import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings extends Equatable {
  Settings({
    required this.loanInterestRate,
    required this.incidentalFeeRate,
    required this.reservationFee,
    required this.lotCategories,
    this.id = Constants.NO_ID,
    required this.perSquareMeterRate,
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  factory Settings.updateId({required String id, required Settings settings}) =>
      Settings(
          loanInterestRate: settings.loanInterestRate,
          incidentalFeeRate: settings.incidentalFeeRate,
          reservationFee: settings.reservationFee,
          lotCategories: settings.lotCategories,
          id: id,
          perSquareMeterRate: settings.perSquareMeterRate);

  factory Settings.defaultSettings() => Settings(
        loanInterestRate: 7,
        incidentalFeeRate: 10,
        lotCategories: const [
          'Corner Lot',
          'Interior Lot',
          'Commercial Lot',
        ],
        reservationFee: 30000,
        perSquareMeterRate: 9000,
      );

  num loanInterestRate;
  num incidentalFeeRate;
  num reservationFee;
  num perSquareMeterRate;
  List<String> lotCategories;
  final String id;

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  @override
  List<Object?> get props =>
      [loanInterestRate, incidentalFeeRate, reservationFee, lotCategories, id];
}
