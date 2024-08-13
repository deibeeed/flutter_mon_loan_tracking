import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/exceptions/settings_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/features/settings/bloc/setting_field.dart';
import 'package:flutter_mon_loan_tracking/models/settings.dart';
import 'package:flutter_mon_loan_tracking/repositories/settings_repository.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required this.settingsRepository}) : super(SettingsInitial()) {
    // on<SettingsEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on(_handleSettingsRetrieved);
    on(_handleSettingsUpdate);
    on(_handleUIupdate);
    getSettings();
  }

  final SettingsRepository settingsRepository;

  late Settings _settings;

  Settings get settings => _settings;

  String? selectedLotCategoryKeyToUpdate = null;

  void getSettings() {
    add(GetSettingsEvent(id: Random().nextInt(1000).toString()));
  }

  Future<void> initializeFuture() async {
    final settingsList = await settingsRepository.all();

    if (settingsList.isEmpty) {
      // defaultSettings
      final tmpSettings = Settings.defaultSettings();
      _settings = await settingsRepository.add(data: tmpSettings);
    } else {
      _settings = await settingsRepository.getLatest();
    }
  }

  void saveUpdatedSettings() {
    add(UpdateSettingsEvent(updatedSettings: _settings));
  }

  void updateSettings({required SettingField field, required String value}) {
    if (value.isEmpty) return;

    _settings.loanInterestRate = num.parse(value);

    add(UpdateSettingsUiEvent(updatedSettings: _settings));
  }

  Future<void> _handleSettingsRetrieved(
      GetSettingsEvent event, Emitter<SettingsState> emit) async {
    try {
      emit(const LoadingSettingsState(isLoading: true));

      await initializeFuture();

      emit(const LoadingSettingsState());
      emit(SettingsSuccessState(settings: _settings));
    } on SettingsNotFoundException catch (err) {
      printd(err);
    }
  }

  Future<void> _handleSettingsUpdate(
      UpdateSettingsEvent event, Emitter<SettingsState> emit) async {
    try {
      emit(const LoadingSettingsState(isLoading: true));

      event.updatedSettings.createdAt = DateTime.now().millisecondsSinceEpoch;

      final settingsList =
          await settingsRepository.add(data: event.updatedSettings);
      _settings = event.updatedSettings;

      emit(const LoadingSettingsState());
      emit(
        SettingsSuccessState(
          settings: _settings,
          message: 'Successfully updated settings',
        ),
      );
    } on SettingsNotFoundException catch (err) {
      printd(err);
    }
  }

  void _handleUIupdate(
      UpdateSettingsUiEvent event, Emitter<SettingsState> emit) {
    selectedLotCategoryKeyToUpdate = null;
    emit(SettingsSuccessState(settings: _settings));
  }
}
