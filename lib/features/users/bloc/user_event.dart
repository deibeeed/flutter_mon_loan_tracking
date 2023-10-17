part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class AddUserEvent extends UserEvent {
  final Map<String, dynamic> values;
  AddUserEvent({ required this.values });
}

class UpdateUserEvent extends UserEvent {
  final Map<String, dynamic> values;

  UpdateUserEvent({ required this.values, });
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

class UpdateBeneficiaryEvent extends UserEvent {
  final Beneficiary beneficiary;

  UpdateBeneficiaryEvent({ required this.beneficiary });
}
