part of 'splash_bloc.dart';

@immutable
abstract class SplashEvent {}

class SplashGoToEvent extends SplashEvent {
  SplashGoToEvent({ required this.goto });

  final String goto;
}