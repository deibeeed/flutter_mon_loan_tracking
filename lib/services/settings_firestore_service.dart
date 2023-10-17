import 'package:flutter_mon_loan_tracking/exceptions/settings_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/settings.dart';
import 'package:flutter_mon_loan_tracking/services/base_firebase_service.dart';

class SettingsFireStoreService extends BaseFirestoreService<Settings> {
  @override
  Future<Settings> add({required Settings data}) async {
    final doc = root.doc();
    final updatedSettings = Settings.updateId(id: doc.id, settings: data);

    await doc.set(updatedSettings.toJson());

    return updatedSettings;
  }

  @override
  Future<List<Settings>> all() async {
    final doc = await root.orderBy('createdAt', descending: true).get();
    final Settingss = doc.docs
        .map((e) => Settings.fromJson(e.data() as Map<String, dynamic>))
        .toList();

    return Settingss;
  }

  @override
  Future<Settings> delete({required Settings data}) async {
    final doc = root.doc(data.id);
    await doc.delete();

    return data;
  }

  @override
  Future<Settings> get({required String id}) async {
    final doc = root.doc(id);
    final data = await doc.get();

    if (!data.exists) {
      return Future.error(SettingsNotFoundException());
    }

    return Settings.fromJson(data.data() as Map<String, dynamic>);
  }

  @override
  Future<Settings> update({required Settings data}) async {
    final doc = root.doc(data.id);

    await doc.set(data.toJson());

    return data;
  }

  Future<Settings> getLatest() async {
    final data =
        await root.orderBy('createdAt', descending: true).limit(1).get();

    return data.docs
        .map((e) => Settings.fromJson(e.data() as Map<String, dynamic>))
        .first;
  }

  @override
  String get collectionName => 'settings';
}
