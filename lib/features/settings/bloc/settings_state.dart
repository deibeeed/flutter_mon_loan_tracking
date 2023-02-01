part of 'settings_bloc.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  // @override
  // List<Object> get props => [];
}

class SettingsSuccessState extends SettingsState {
  const SettingsSuccessState({ required this.settings, this.message });
  
  final Settings settings;
  final String? message;
  
  // @override
  // List<Object?> get props => [
  //   settings,
  //   message
  // ];
}

class SettingsErrorState extends SettingsState {
  const SettingsErrorState({ required this.message });
  final String message;

  // @override
  // List<Object?> get props => [
  //   message,
  // ];
}

class LoadingSettingsState extends SettingsState {
  const LoadingSettingsState({ this.isLoading = false, this.loadingMessage});

  final bool isLoading;
  final String? loadingMessage;

  // @override
  // List<Object?> get props => [
  //   isLoading,
  //   loadingMessage,
  // ];
}