import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address extends Equatable {
  final String houseNo;
  final String street;
  final String brgy;
  final String zone;
  final String city;
  final String province;
  final String zipCode;
  final String country;
  final String userId;
  final String id;
  final num createdAt = DateTime.now().millisecondsSinceEpoch;

  Address({
    required this.houseNo,
    required this.street,
    required this.brgy,
    required this.zone,
    required this.city,
    required this.province,
    required this.zipCode,
    required this.country,
    required this.userId,
    this.id = Constants.NO_ID,
});

  @override
  List<Object?> get props => [
    houseNo,
    street,
    brgy,
    zone,
    city,
    province,
    zipCode,
    country,
    userId,
    id,
    createdAt,
  ];

}