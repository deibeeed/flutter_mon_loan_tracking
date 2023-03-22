import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address extends Equatable {
  String houseNo;
  String street;
  String brgy;
  String zone;
  String city;
  String province;
  String zipCode;
  String country;
  String userId;
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

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  factory Address.createBlank() => Address(
        houseNo: '',
        street: '',
        brgy: '',
        zone: '',
        city: '',
        province: '',
        zipCode: '',
        country: '',
        userId: '',
      );

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  factory Address.updateId({required String id, required Address address}) =>
      Address(
        id: id,
        houseNo: address.houseNo,
        street: address.street,
        brgy: address.brgy,
        zone: address.zone,
        city: address.city,
        province: address.province,
        zipCode: address.zipCode,
        country: address.country,
        userId: address.userId,
      );

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
