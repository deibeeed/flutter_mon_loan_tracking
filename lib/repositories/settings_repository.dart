import 'package:flutter_mon_loan_tracking/models/settings.dart';
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/settings_firestre_service.dart';

class SettingsRepository extends BaseRepository<Settings> {
  SettingsRepository({
    required this.firestoreService,
  });
  final SettingsFireStoreService firestoreService;

  @override
  Future<Settings> add({required Settings data}) {
    return firestoreService.add(data: data);
  }

  @override
  Future<List<Settings>> all() {
    return firestoreService.all();
  }

  @override
  Future<Settings> delete({required Settings data}) {
    return firestoreService.delete(data: data);
  }

  @override
  Future<Settings> get({required String id}) {
    return firestoreService.get(id: id);
  }

  @override
  Future<Settings> update({required Settings data}) {
    return firestoreService.update(data: data);
  }

}