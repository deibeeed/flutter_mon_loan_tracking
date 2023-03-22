import 'package:flutter_mon_loan_tracking/exceptions/beneficiary_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/beneficiary.dart';
import 'package:flutter_mon_loan_tracking/services/base_firebase_service.dart';

class BeneficiaryFirestoreService extends BaseFirestoreService<Beneficiary> {
  @override
  Future<Beneficiary> add({required Beneficiary data}) async {
    final doc = root.doc(data.id);
    // final updatedUser = Beneficiary.updateId(id: doc.id, user: data);

    await doc.set(data.toJson());

    return data;
  }

  @override
  Future<List<Beneficiary>> all() async {
    final doc = await root.orderBy('lastName').get();
    final beneficiaries = doc.docs
        .map((e) => Beneficiary.fromJson(e.data() as Map<String, dynamic>))
        .toList();

    return beneficiaries;
  }

  @override
  Future<Beneficiary> delete({required Beneficiary data}) async {
    final doc = root.doc(data.id);
    await doc.delete();

    return data;
  }

  @override
  Future<Beneficiary> get({required String id}) async {
    final doc = root.doc(id);
    final data = await doc.get();

    if (!data.exists) {
      return Future.error(BeneficiaryNotFoundException());
    }

    return Beneficiary.fromJson(data.data() as Map<String, dynamic>);
  }

  @override
  Future<Beneficiary> update({required Beneficiary data}) async {
    final doc = root.doc(data.id);

    await doc.set(data.toJson());

    return data;
  }

  @override
  String get collectionName => 'beneficiary';
}