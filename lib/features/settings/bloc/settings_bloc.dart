import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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

  void getSettings() {
    add(GetSettingsEvent(id: Random().nextInt(1000).toString()));
  }

  void saveUpdatedSettings() {
    add(UpdateSettingsEvent(updatedSettings: _settings));
  }

  void updateSettings({required SettingField field, required String value}) {
    if (value.isEmpty) return;

    switch (field) {
      case SettingField.loanInterestRate:
        _settings.loanInterestRate = num.parse(value);
        break;
      case SettingField.incidentalFeeRate:
        _settings.incidentalFeeRate = num.parse(value);
        break;
      case SettingField.reservationFee:
        _settings.reservationFee = num.parse(value);
        break;
      case SettingField.lotCategory:
        _settings.lotCategories.add(value);
        break;
      case SettingField.perSquareMeterRate:
        _settings.perSquareMeterRate = num.parse(value);
        break;
    }

    add(UpdateSettingsUiEvent(updatedSettings: _settings));
  }

  void removeLotCategory({required String category}) {
    _settings.lotCategories.removeWhere((element) => element == category);
    add(UpdateSettingsUiEvent(updatedSettings: _settings));
  }

  Future<void> _handleSettingsRetrieved(
      GetSettingsEvent event, Emitter<SettingsState> emit) async {
    try {
      emit(const LoadingSettingsState(isLoading: true));

      final settingsList = await settingsRepository.all();

      if (settingsList.isEmpty) {
        // defaultSettings
        final tmpSettings = Settings.defaultSettings();
        _settings = await settingsRepository.add(data: tmpSettings);
      } else {
        _settings = settingsList[0];
      }

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
    emit(SettingsSuccessState(settings: _settings));
  }
}
