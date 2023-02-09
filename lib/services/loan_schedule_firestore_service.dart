import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_mon_loan_tracking/exceptions/loan_schedule_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/services/base_firebase_service.dart';

class LoanScheduleFirestoreService extends BaseFirestoreService<LoanSchedule> {
  DocumentSnapshot? _lastDocumentSnapshot;

  @override
  Future<LoanSchedule> add({required LoanSchedule data}) async {
    final doc = root.doc();
    final updatedUser = LoanSchedule.updateId(id: doc.id, loanSchedule: data);

    await doc.set(updatedUser.toJson());

    return updatedUser;
  }

  @override
  Future<List<LoanSchedule>> all() async {
    final doc = await root.orderBy('createdAt').get();
    final users = doc.docs
        .map((e) => LoanSchedule.fromJson(e.data() as Map<String, dynamic>))
        .toList();

    return users;
  }

  Future<List<LoanSchedule>> next() async {
    var query = root.orderBy('createdAt');
    
    if (_lastDocumentSnapshot != null) {
      query = query.startAfterDocument(_lastDocumentSnapshot!);
    }

    final doc = await query.limit(10).get();
    
    final schedules = doc.docs
        .map((e) => LoanSchedule.fromJson(e.data() as Map<String, dynamic>))
        .toList();

    _lastDocumentSnapshot = doc.docs.last;

    return schedules.sortedBy((schedule) => schedule.date);
  }

  @override
  Future<LoanSchedule> delete({required LoanSchedule data}) async {
    final doc = root.doc(data.id);
    await doc.delete();

    return data;
  }

  @override
  Future<LoanSchedule> get({required String id}) async {
    final doc = root.doc(id);
    final data = await doc.get();

    if (!data.exists) {
      return Future.error(LoanScheduleNotFoundException());
    }

    return LoanSchedule.fromJson(data.data() as Map<String, dynamic>);
  }

  @override
  Future<LoanSchedule> update({required LoanSchedule data}) async {
    final doc = root.doc(data.id);

    await doc.set(data.toJson());

    return data;
  }

  @override
  String get collectionName => 'loan_schedules';
}