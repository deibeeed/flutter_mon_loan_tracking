import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/loan_firestore_service.dart';

class LoanRepository extends BaseRepository<Loan> {
  LoanRepository({
    required this.firestoreService,
  });

  final LoanFirestoreService firestoreService;

  @override
  Future<Loan> add({required Loan data}) {
    return firestoreService.add(data: data);
  }

  @override
  Future<List<Loan>> all({
    bool onlyFullPaid = false,
  }) {
    return firestoreService.all(onlyFullPaid: onlyFullPaid);
  }

  Future<List<Loan>> allLoans() {
    return firestoreService.allLoans();
  }

  Future<Loan?> clientLastLoan(String clientId) {
    return firestoreService.clientLastLoan(clientId);
  }

  @override
  Future<Loan> delete({required Loan data}) {
    return firestoreService.delete(data: data);
  }

  @override
  Future<Loan> get({required String id}) {
    return firestoreService.get(id: id);
  }

  @override
  Future<Loan> update({required Loan data}) {
    return firestoreService.update(data: data);
  }
}
