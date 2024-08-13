import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings extends Equatable {
  Settings({
    required this.loanInterestRate,
    this.id = Constants.NO_ID,
    this.createdAt = Constants.NO_DATE,
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  factory Settings.updateId({required String id, required Settings settings}) =>
      Settings(
          loanInterestRate: settings.loanInterestRate,
          id: id,
          createdAt: settings.createdAt,
      );

  factory Settings.defaultSettings() =>
      Settings(
        loanInterestRate: 7,
        createdAt: DateTime
            .now()
            .millisecondsSinceEpoch,
      );

  num loanInterestRate;
  final String id;
  num createdAt;

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  @override
  List<Object?> get props =>
      [
        loanInterestRate,
        id,
        createdAt,
      ];
}
