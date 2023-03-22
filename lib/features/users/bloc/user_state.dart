part of 'user_bloc.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserSuccessState extends UserState {
  final String message;
  final User? user;

  UserSuccessState({
    this.user,
    required this.message,
  });
}

class UserErrorState extends UserState {
  final String message;

  UserErrorState({
    required this.message,
  });
}

class UserLoadingState extends UserState {
  final bool isLoading;
  final String? message;

  UserLoadingState({
    this.isLoading = false,
    this.message,
  });
}

class SelectedUserTypeState extends UserState {
  final UserType type;

  SelectedUserTypeState({ required this.type});
}

class SelectedCivilStatusState extends UserState {
  final CivilStatus civilStatus;

  SelectedCivilStatusState({ required this.civilStatus});
}

class SelectedGenderState extends UserState {
  final Gender gender;

  SelectedGenderState({ required this.gender});
}

class CloseScreenState extends UserState { }

class UpdateUiState extends UserState { }
