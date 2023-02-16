import 'package:flutter_mon_loan_tracking/models/lot.dart';
import 'package:flutter_mon_loan_tracking/repositories/base_repository.dart';
import 'package:flutter_mon_loan_tracking/services/lot_cache_service.dart';
import 'package:flutter_mon_loan_tracking/services/lot_firestore_service.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

class LotRepository extends BaseRepository<Lot> {
  LotRepository({
    required this.firestoreService,
    required this.cacheService,
  });

  final LotFirestoreService firestoreService;
  final LotCacheService cacheService;

  @override
  Future<Lot> add({required Lot data}) {
    return firestoreService.add(data: data)
    .then((value) => cacheService.add(data: value));
  }

  @override
  Future<List<Lot>> all() {
    return firestoreService.all()
    .then((value) => cacheService.addAll(lots: value));
  }

  Future<List<Lot>> allCache() {
    return cacheService.all();
  }

  @override
  Future<Lot> delete({required Lot data}) {
    return firestoreService.delete(data: data)
    .then((value) => cacheService.delete(data: value));
  }

  @override
  Future<Lot> get({required String id}) {
    try {
      return cacheService.get(id: id);
    } catch (err) {
      printd(err);
    }
    return firestoreService.get(id: id)
    .then((value) => cacheService.add(data: value));
  }

  @override
  Future<Lot> update({required Lot data}) {
    return firestoreService.update(data: data)
    .then((value) => cacheService.update(data: value));
  }

  Future<Lot> searchLot({
    required String blockNo,
    required String lotNo,
  }) {
    final searchedLot = cacheService.searchLot(blockNo: blockNo, lotNo: lotNo);
    
    if (searchedLot != null) {
      return Future.value(searchedLot);
    }
    
    return firestoreService.searchLot(blockNo: blockNo, lotNo: lotNo)
    .then((value) => cacheService.add(data: value));
  }
}
