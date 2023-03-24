part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class AddUserEvent extends UserEvent {
  final Map<String, dynamic> values;
  AddUserEvent({ required this.values });
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

class RemoveBeneficiaryEvent extends UserEvent {
  final Beneficiary beneficiary;

  RemoveBeneficiaryEvent({ required this.beneficiary, });
}
