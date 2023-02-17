part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class AddUserEvent extends UserEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String birthDate;
  final String civilStatus;
  final String mobileNumber;
  final UserType type;
  String? password;
  String? confirmPassword;

  AddUserEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.civilStatus,
    required this.mobileNumber,
    required this.type,
    this.password,
    this.confirmPassword,
  });
}

class UpdateUserEvent extends UserEvent {
  final User user;

  UpdateUserEvent({ required this.user });
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