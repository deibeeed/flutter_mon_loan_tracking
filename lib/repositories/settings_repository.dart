import 'package:flutter_mon_loan_tracking/exceptions/settings_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/settings.dart';
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/settings_cache_service.dart';
import 'package:flutter_mon_loan_tracking/services/settings_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

class SettingsRepository extends BaseRepository<Settings> {
  SettingsRepository({
    required this.firestoreService,
    required this.cacheService,
  });

  final SettingsFireStoreService firestoreService;
  final SettingsCacheService cacheService;

  @override
  Future<Settings> add({required Settings data}) {
    return firestoreService
        .add(data: data)
        .then((value) => cacheService.add(data: value));
  }

  @override
  Future<List<Settings>> all() {
    return firestoreService.all();
  }

  @override
  Future<Settings> delete({required Settings data}) {
    return firestoreService.delete(data: data)
    .then((value) => cacheService.delete(data: value));
  }

  @override
  Future<Settings> get({required String id}) {
    return firestoreService.get(id: id);
  }

  @override
  Future<Settings> update({required Settings data}) {
    return firestoreService.update(data: data)
    .then((value) => cacheService.update(data: value));
  }

  Future<Settings> getLatest() async {
    try {
      final tmp = await cacheService.get(id: 'n/a');
      return tmp;
    } on SettingsNotFoundException catch (err) {
      printd('err: $err');
    }
    
    return firestoreService.getLatest()
    .then((value) => cacheService.add(data: value));
  }
}
