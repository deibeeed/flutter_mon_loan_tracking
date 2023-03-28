part of 'user_bloc.dart';

@immutable
abstract class UserState  extends Equatable {}

class UserInitial extends UserState {
  @override
  List<Object?> get props => [];
}

class UserSuccessState extends UserState {
  final String message;
  final User? user;

  UserSuccessState({
    this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [
    user,
    message,
  ];
}

class UserErrorState extends UserState {
  final String message;

  UserErrorState({
    required this.message,
  });

  @override
  List<Object?> get props => [
    message,
  ];
}

class UserLoadingState extends UserState {
  final bool isLoading;
  final String? message;

  UserLoadingState({
    this.isLoading = false,
    this.message,
  });

  @override
  List<Object?> get props => [
    isLoading,
    message,
  ];
}

class SelectedUserTypeState extends UserState {
  final UserType type;

  SelectedUserTypeState({ required this.type});

  @override
  List<Object?> get props => [
    type,
  ];
}

class SelectedCivilStatusState extends UserState {
  final CivilStatus civilStatus;

  SelectedCivilStatusState({ required this.civilStatus});

  @override
  List<Object?> get props => [
    civilStatus,
  ];
}

class SelectedGenderState extends UserState {
  final Gender gender;

  SelectedGenderState({ required this.gender});

  @override
  List<Object?> get props => [
    gender,
  ];
}

class CloseScreenState extends UserState {
  @override
  List<Object?> get props => [
    Random().nextInt(9999),
  ];
 }

class UpdateUiState extends UserState {
  final String? removeFieldsThatStartsWithKey;
  final Map<String, dynamic>? showValues;

  UpdateUiState({ this.removeFieldsThatStartsWithKey, this.showValues });

  @override
  List<Object?> get props => [
    removeFieldsThatStartsWithKey,
    showValues,
    Random().nextInt(9999),
  ];
}

class RemoveUiState extends UserState {
  final String? removeFieldsThatStartsWithKey;

  RemoveUiState({ this.removeFieldsThatStartsWithKey });

  @override
  List<Object?> get props => [
    removeFieldsThatStartsWithKey,
    Random().nextInt(9999),
  ];
}
