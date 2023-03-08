part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {
  const SettingsEvent();
}

class GetSettingsEvent extends SettingsEvent {
  const GetSettingsEvent({ this.id });

  final String? id;
}

class UpdateSettingsEvent extends SettingsEvent {
  const UpdateSettingsEvent({ required this.updatedSettings });

  final Settings updatedSettings;
}

class UpdateSettingsUiEvent extends SettingsEvent {
  const UpdateSettingsUiEvent({ required this.updatedSettings });

  final Settings updatedSettings;
}

