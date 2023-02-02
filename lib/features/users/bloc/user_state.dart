part of 'user_bloc.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserSuccessState extends UserState {
  final String? message;
  final User user;

  UserSuccessState({
    required this.user,
    this.message,
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
