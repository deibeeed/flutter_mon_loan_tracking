import 'package:flutter_mon_loan_tracking/exceptions/settings_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/settings.dart';
import 'package:flutter_mon_loan_tracking/services/base_cache_service.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

class SettingsCacheService extends BaseCacheService<Settings> {
  Settings? _settings;

  @override
  Future<Settings> add({required Settings data}) async {
    _settings = data;

    return _settings!;
  }

  @override
  Future<List<Settings>> all() async{
    if (_settings == null) {
      printd('Settings not found in cache');
      return [];
    }

    return [_settings!];
  }

  @override
  Future<Settings> delete({required Settings data}) async {
    if (_settings == null) {
      printd('Settings not found in cache');
      return data;
    }

    _settings = null;

    return data;
  }

  @override
  Future<Settings> get({required String id}) async {
    if (_settings == null) {
      throw SettingsNotFoundException(message: 'Settings not found in cache');
    }

    return _settings!;
  }

  @override
  Future<Settings> update({required Settings data}) async {
    return add(data: data);
  }

}