import 'package:flutter_mon_loan_tracking/models/employment_details.dart';
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/employment_details_firestore_service.dart';

class EmploymentDetailsRepository extends BaseRepository<EmploymentDetails> {
  EmploymentDetailsRepository({
    required this.firestoreService,
  });
  final EmploymentDetailsFirestoreService firestoreService;

  @override
  Future<EmploymentDetails> add({required EmploymentDetails data}) {
    return firestoreService.add(data: data);
  }

  @override
  Future<List<EmploymentDetails>> all() {
    return firestoreService.all();
  }

  @override
  Future<EmploymentDetails> delete({required EmploymentDetails data}) {
    return firestoreService.delete(data: data);
  }

  @override
  Future<EmploymentDetails> get({required String id}) {
    return firestoreService.get(id: id);
  }

  @override
  Future<EmploymentDetails> update({required EmploymentDetails data}) {
    return firestoreService.update(data: data);
  }
}