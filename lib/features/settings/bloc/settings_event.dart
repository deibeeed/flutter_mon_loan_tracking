part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {
  const SettingsEvent();
}

class GetSettingsEvent extends SettingsEvent {
  const GetSettingsEvent({ this.id });

  final String? id;
  // @override
  // List<Object?> get props => [
  //   id,
  // ];
}

class UpdateSettingsEvent extends SettingsEvent {
  const UpdateSettingsEvent({ required this.updatedSettings });

  final Settings updatedSettings;

  // @override
  // List<Object?> get props => [
  //   updatedSettings
  // ];
}

class UpdateSettingsUiEvent extends SettingsEvent {
  const UpdateSettingsUiEvent({ required this.updatedSettings });

  final Settings updatedSettings;

  // @override
  // List<Object?> get props => [
  //   updatedSettings
  // ];
}