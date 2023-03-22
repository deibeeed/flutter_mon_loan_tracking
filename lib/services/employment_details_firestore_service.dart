import 'package:flutter_mon_loan_tracking/exceptions/employment_details_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/employment_details.dart';
import 'package:flutter_mon_loan_tracking/services/base_firebase_service.dart';

class EmploymentDetailsFirestoreService extends BaseFirestoreService<EmploymentDetails> {
  @override
  Future<EmploymentDetails> add({required EmploymentDetails data}) async {
    final doc = root.doc(data.id);
    // final updatedUser = EmploymentDetails.updateId(id: doc.id, user: data);

    await doc.set(data.toJson());

    return data;
  }

  @override
  Future<List<EmploymentDetails>> all() async {
    final doc = await root.orderBy('lastName').get();
    final details = doc.docs
        .map((e) => EmploymentDetails.fromJson(e.data() as Map<String, dynamic>))
        .toList();

    return details;
  }

  @override
  Future<EmploymentDetails> delete({required EmploymentDetails data}) async {
    final doc = root.doc(data.id);
    await doc.delete();

    return data;
  }

  @override
  Future<EmploymentDetails> get({required String id}) async {
    final doc = root.doc(id);
    final data = await doc.get();

    if (!data.exists) {
      return Future.error(EmploymentDetailsNotFoundException());
    }

    return EmploymentDetails.fromJson(data.data() as Map<String, dynamic>);
  }

  @override
  Future<EmploymentDetails> update({required EmploymentDetails data}) async {
    final doc = root.doc(data.id);

    await doc.set(data.toJson());

    return data;
  }

  @override
  String get collectionName => 'employment_details';
}