part of 'splash_bloc.dart';

@immutable
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashGoToState extends SplashState {
  SplashGoToState({ required this.goto });
  final String goto;
}
