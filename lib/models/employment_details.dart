import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'employment_details.g.dart';

@JsonSerializable()
class EmploymentDetails extends Equatable {
  String companyName;
  String natureOfBusiness;
  String address;
  String position;
  num years;
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

  Map<String, dynamic> toJson() => _$EmploymentDetailsToJson(this);

  factory EmploymentDetails.createBlank() => EmploymentDetails(
        companyName: '',
        natureOfBusiness: '',
        address: '',
        position: '',
        years: -1,
      );

  factory EmploymentDetails.fromJson(Map<String, dynamic> json) =>
      _$EmploymentDetailsFromJson(json);

  factory EmploymentDetails.updateId(
          {required String id, required EmploymentDetails employmentDetails}) =>
      EmploymentDetails(
        companyName: employmentDetails.companyName,
        natureOfBusiness: employmentDetails.natureOfBusiness,
        address: employmentDetails.address,
        position: employmentDetails.position,
        years: employmentDetails.years,
        id: id
      );

  @override
  List<Object?> get props => [
        companyName,
        natureOfBusiness,
        address,
        position,
        years,
      ];
}
