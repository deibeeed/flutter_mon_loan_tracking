import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/gender.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'beneficiary.g.dart';

@JsonSerializable()
class Beneficiary extends Equatable {
  String name;
  num birthDate;
  String relationship;
  Gender gender;
  final String id;
  String parentId;
  final num createdAt = DateTime.now().millisecondsSinceEpoch;

  Beneficiary({
    required this.name,
    required this.birthDate,
    required this.relationship,
    required this.gender,
    this.id = Constants.NO_ID,
    required this.parentId,
  });

  Map<String, dynamic> toJson() => _$BeneficiaryToJson(this);

  factory Beneficiary.createBlank() => Beneficiary(
        name: '',
        birthDate: -1,
        relationship: '',
        gender: Gender.male,
        parentId: '',
      );

  factory Beneficiary.fromJson(Map<String, dynamic> json) =>
      _$BeneficiaryFromJson(json);

  factory Beneficiary.updateId(
          {required String id, required Beneficiary benificiary}) =>
      Beneficiary(
          name: benificiary.name,
          birthDate: benificiary.birthDate,
          relationship: benificiary.relationship,
          gender: benificiary.gender,
          id: id,
          parentId: benificiary.parentId);

  @override
  List<Object?> get props => [
        name,
        birthDate,
        relationship,
        gender,
        id,
        parentId,
        createdAt,
      ];
}
