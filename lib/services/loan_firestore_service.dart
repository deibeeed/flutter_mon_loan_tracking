import 'package:flutter_mon_loan_tracking/exceptions/loan_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/services/base_firebase_service.dart';

class LoanFirestoreService extends BaseFirestoreService<Loan> {
  @override
  Future<Loan> add({required Loan data}) async {
    final doc = root.doc();
    final updatedLoan = Loan.updateId(id: doc.id, loan: data);

    await doc.set(updatedLoan.toJson());

    return updatedLoan;
  }

  @override
  Future<List<Loan>> all() async {
    final doc = await root.get();
    final users = doc.docs
        .map((e) => Loan.fromJson(e.data() as Map<String, dynamic>))
        .toList();

    return users;
  }

  @override
  Future<Loan> delete({required Loan data}) async {
    final doc = root.doc(data.id);
    await doc.delete();

    return data;
  }

  @override
  Future<Loan> get({required String id}) async {
    final doc = root.doc(id);
    final data = await doc.get();

    if (!data.exists) {
      return Future.error(LoanNotFoundException());
    }

    return Loan.fromJson(data.data() as Map<String, dynamic>);
  }

  @override
  Future<Loan> update({required Loan data}) async {
    final doc = root.doc(data.id);

    await doc.set(data.toJson());

    return data;
  }

  @override
  String get collectionName => 'loans';
}