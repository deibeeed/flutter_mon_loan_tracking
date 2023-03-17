import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/gender.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'benificiary.g.dart';

@JsonSerializable()
class Benificiary extends Equatable {
  final String name;
  final num birthDate;
  final String relationship;
  final Gender gender;
  final String id;
  final String? parentId;
  final num createdAt = DateTime.now().millisecondsSinceEpoch;

  Benificiary({
    required this.name,
    required this.birthDate,
    required this.relationship,
    required this.gender,
    this.id = Constants.NO_ID,
this.parentId,
});

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