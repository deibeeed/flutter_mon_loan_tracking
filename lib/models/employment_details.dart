import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'employment_details.g.dart';

@JsonSerializable()
class EmploymentDetails extends Equatable {
  final String companyName;
  final String natureOfBusiness;
  final String address;
  final String position;
  final num years;
  final String id;
  final num createdAt = DateTime.now().millisecondsSinceEpoch;

  EmploymentDetails({
    required this.companyName,
    required this.natureOfBusiness,
    required this.address,
    required this.position,
    required this.years,
    this.id = Constants.NO_ID,
});

  @override
  List<Object?> get props => [
    companyName,
    natureOfBusiness,
    address,
    position,
    years,
  ];

}