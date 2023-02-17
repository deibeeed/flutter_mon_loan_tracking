import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/civil_status_types.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  const User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.civilStatus,
    required this.mobileNumber,
    this.id = Constants.NO_ID,
    this.type = UserType.customer,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.updateId({required String id, required User user}) => User(
        id: id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        birthDate: user.birthDate,
        civilStatus: user.civilStatus,
        mobileNumber: user.mobileNumber,
        type: user.type,
      );

  final String firstName;
  final String lastName;
  final String email;
  final String birthDate;
  final CivilStatus civilStatus;
  final String mobileNumber;
  final String id;
  final UserType type;

  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get completeName => '$lastName, $firstName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        birthDate,
        civilStatus,
        mobileNumber,
        id,
        type,
      ];
}
