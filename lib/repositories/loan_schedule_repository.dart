import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/loan_schedule_firestore_service.dart';

class LoanScheduleRepository extends BaseRepository<LoanSchedule> {
  LoanScheduleRepository({
    required this.firestoreService,
  });
  final LoanScheduleFirestoreService firestoreService;

  @override
  Future<LoanSchedule> add({required LoanSchedule data}) {
    return firestoreService.add(data: data);
  }

  @override
  Future<List<LoanSchedule>> all() {
    return firestoreService.all();
  }

  Future<List<LoanSchedule>> allByLoanId({ required String loanId}) {
    return firestoreService.allByLoanId(loanId: loanId);
  }

  Future<List<LoanSchedule>> next() {
    return firestoreService.next();
  }

  @override
  Future<LoanSchedule> delete({required LoanSchedule data}) {
    return firestoreService.delete(data: data);
  }

  @override
  Future<LoanSchedule> get({required String id}) {
    return firestoreService.get(id: id);
  }

  @override
  Future<LoanSchedule> update({required LoanSchedule data}) {
    return firestoreService.update(data: data);
  }
}