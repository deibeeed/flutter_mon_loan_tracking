part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
}

class AuthenticationInitial extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class LoginSuccessState extends AuthenticationState {
  const LoginSuccessState({ required this.message, this.user = null,});
  final String message;
  final User? user;

  @override
  List<Object?> get props => [
    message,
    user
  ];

}

class LoginErrorState extends AuthenticationState {
  const LoginErrorState({ required this.message });
  final String message;

  @override
  List<Object?> get props => [
    message,
  ];

}

class LoginLoadingState extends AuthenticationState {
  const LoginLoadingState({ this.isLoading = false, this.loadingMessage});
  final String? loadingMessage;
  final bool isLoading;

  @override
  List<Object?> get props => [
    isLoading,
    loadingMessage,
  ];

}

class LogoutSuccessState extends AuthenticationState {
  @override
  List<Object?> get props => [
    Random().nextInt(9999)
  ];
}

class UiEmitState extends AuthenticationState {
  @override
  List<Object?> get props => [
    Random().nextInt(9999),
  ];

}
