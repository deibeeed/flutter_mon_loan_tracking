import 'package:flutter_mon_loan_tracking/exceptions/employment_details_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/employment_details.dart';
import 'package:flutter_mon_loan_tracking/services/base_firebase_service.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';

class EmploymentDetailsFirestoreService
    extends BaseFirestoreService<EmploymentDetails> {
  @override
  Future<EmploymentDetails> add({required EmploymentDetails data}) async {
    var doc = root.doc();

    if (data.id != Constants.NO_ID) {
      doc = root.doc(data.id);
      await doc.set(data.toJson());

      return data;
    } else {
      final updatedEmploymentDetails = EmploymentDetails.updateId(
        id: doc.id,
        employmentDetails: data,
      );

      await doc.set(updatedEmploymentDetails.toJson());

      return updatedEmploymentDetails;
    }
  }

  @override
  Future<List<EmploymentDetails>> all() async {
    final doc = await root.orderBy('lastName').get();
    final details = doc.docs
        .map(
            (e) => EmploymentDetails.fromJson(e.data() as Map<String, dynamic>))
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

  Future<EmploymentDetails> getByUserId({required String userId}) async {
    final doc = root.where('userId', isEqualTo: userId).limit(1);
    final data = await doc.get();

    if (data.docs.isEmpty) {
      return Future.error(EmploymentDetailsNotFoundException());
    }

    return EmploymentDetails.fromJson(data.docs[0].data() as Map<String, dynamic>);
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
