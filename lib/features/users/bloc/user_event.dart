part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class AddUserEvent extends UserEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String birthDate;
  final CivilStatus civilStatus;
  final String mobileNumber;
  final UserType type;
  final String password;
  final String confirmPassword;
  final String? middleName;
  final String? gender;
  final String? birthPlace;
  final String? nationality;
  final String? height;
  final String? weight;
  final String? childrenCount;
  final String? tinNo;
  final String? sssNo;
  final String? philHealthNo;
  final String? telNo;
  AddUserEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.civilStatus,
    required this.mobileNumber,
    required this.type,
    required this.password,
    required this.confirmPassword,
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
    this.telNo,
  });
}

class UpdateUserEvent extends UserEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String birthDate;
  final CivilStatus civilStatus;
  final String mobileNumber;

  UpdateUserEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.civilStatus,
    required this.mobileNumber,
  });
}

class GetAllUsersEvent extends UserEvent { }

class SearchUsersEvent extends UserEvent {
  final String query;

  SearchUsersEvent({ required this.query });
}

class GetUserEvent extends UserEvent {
  final String userId;

  GetUserEvent({ required this.userId });
}
