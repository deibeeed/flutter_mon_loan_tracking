part of 'settings_bloc.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
}

class SettingsSuccessState extends SettingsState {
  const SettingsSuccessState({ required this.settings, this.message });
  
  final Settings settings;
  final String? message;
}

class SettingsErrorState extends SettingsState {
  const SettingsErrorState({ required this.message });
  final String message;
}

class LoadingSettingsState extends SettingsState {
  const LoadingSettingsState({ this.isLoading = false, this.loadingMessage});

  final bool isLoading;
  final String? loadingMessage;
}

class LotCategorySelectedState extends SettingsState {
  final LotCategory category;

  const LotCategorySelectedState({ required this.category});
}

