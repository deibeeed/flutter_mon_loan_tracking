import 'package:flutter_mon_loan_tracking/exceptions/lot_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/lot.dart';
import 'package:flutter_mon_loan_tracking/services/base_firebase_service.dart';

class LotFirestoreService extends BaseFirestoreService<Lot> {
  @override
  Future<Lot> add({required Lot data}) async {
    final doc = root.doc();
    final updatedUser = Lot.updateId(id: doc.id, lot: data);

    await doc.set(updatedUser.toJson());

    return updatedUser;
  }

  @override
  Future<List<Lot>> all() async {
    final doc = await root.get();
    final users = doc.docs
        .map((e) => Lot.fromJson(e.data() as Map<String, dynamic>))
        .toList();

    return users;
  }

  @override
  Future<Lot> delete({required Lot data}) async {
    final doc = root.doc(data.id);
    await doc.delete();

    return data;
  }

  @override
  Future<Lot> get({required String id}) async {
    final doc = root.doc(id);
    final data = await doc.get();

    if (!data.exists) {
      return Future.error(LotNotFoundException());
    }

    return Lot.fromJson(data.data() as Map<String, dynamic>);
  }

  @override
  Future<Lot> update({required Lot data}) async {
    final doc = root.doc(data.id);

    await doc.set(data.toJson());

    return data;
  }

  @override
  String get collectionName => 'lots';
}