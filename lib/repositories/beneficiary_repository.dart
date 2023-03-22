import 'package:flutter_mon_loan_tracking/models/beneficiary.dart';
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/beneficiary_firestore_service.dart';

class BeneficiaryRepository extends BaseRepository<Beneficiary> {
  BeneficiaryRepository({
    required this.firestoreService,
  });
  final BeneficiaryFirestoreService firestoreService;

  @override
  Future<Beneficiary> add({required Beneficiary data}) {
    return firestoreService.add(data: data);
  }

  @override
  Future<List<Beneficiary>> all() {
    return firestoreService.all();
  }

  @override
  Future<Beneficiary> delete({required Beneficiary data}) {
    return firestoreService.delete(data: data);
  }

  @override
  Future<Beneficiary> get({required String id}) {
    return firestoreService.get(id: id);
  }

  @override
  Future<Beneficiary> update({required Beneficiary data}) {
    return firestoreService.update(data: data);
  }
}