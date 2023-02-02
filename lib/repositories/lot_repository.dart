import 'package:flutter_mon_loan_tracking/models/lot.dart';
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/lot_firestore_service.dart';

class LotRepository extends BaseRepository<Lot> {
  LotRepository({
    required this.firestoreService,
  });
  final LotFirestoreService firestoreService;

  @override
  Future<Lot> add({required Lot data}) {
    return firestoreService.add(data: data);
  }

  @override
  Future<List<Lot>> all() {
    return firestoreService.all();
  }

  @override
  Future<Lot> delete({required Lot data}) {
    return firestoreService.delete(data: data);
  }

  @override
  Future<Lot> get({required String id}) {
    return firestoreService.get(id: id);
  }

  @override
  Future<Lot> update({required Lot data}) {
    return firestoreService.update(data: data);
  }
}