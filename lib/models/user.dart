import 'package:equatable/equatable.dart';
import 'package:flutter_mon_loan_tracking/models/civil_status_types.dart';
import 'package:flutter_mon_loan_tracking/models/gender.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.civilStatus,
    required this.mobileNumber,
    this.id = Constants.NO_ID,
    this.type = UserType.customer,
    this.middleName,
    this.gender,
    this.birthPlace,
    this.nationality,
    this.height,
    this.weight,
    this.childrenCount,
    this.tinNo,
    this.sssNo,
    this.philHealthNo,
    this.spouseId,
    this.telNo,
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
        middleName: user.middleName,
        gender: user.gender,
        birthPlace: user.birthPlace,
        nationality: user.nationality,
        height: user.height,
        weight: user.weight,
        childrenCount: user.childrenCount,
        tinNo: user.tinNo,
        sssNo: user.sssNo,
        philHealthNo: user.philHealthNo,
        spouseId: user.spouseId,
        telNo: user.telNo,
      );

  factory User.createBlank() => User(
    firstName: '',
    lastName: '',
    mobileNumber: '',
    civilStatus: CivilStatus.single,
    birthDate: '',
    email: '',
    gender: Gender.male,
  );

  String firstName;
  String lastName;
  String email;
  String birthDate;
  CivilStatus civilStatus;
  String mobileNumber;
  String id;
  UserType type;
  String? spouseId;
  String? middleName;
  Gender? gender;
  String? birthPlace;
  String? nationality;
  num? height;
  num? weight;
  num? childrenCount;
  String? tinNo;
  String? sssNo;
  String? philHealthNo;
  String? telNo;
  final num createdAt = DateTime.now().millisecondsSinceEpoch;

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
        middleName,
        gender,
        birthPlace,
        nationality,
        height,
        weight,
        childrenCount,
        tinNo,
        sssNo,
        philHealthNo,
        spouseId,
        telNo,
        createdAt,
      ];
}
