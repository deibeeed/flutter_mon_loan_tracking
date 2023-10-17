import 'package:collection/collection.dart';
import 'package:flutter_mon_loan_tracking/exceptions/lot_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/lot.dart';
import 'package:flutter_mon_loan_tracking/services/base_cache_service.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

class LotCacheService extends BaseCacheService<Lot> {
  final Map<String, Lot> _mappedLots = {};

  @override
  Future<Lot> add({required Lot data}) async {
    _mappedLots[data.id] = data;

    return data;
  }

  @override
  Future<List<Lot>> all() async {
    return _mappedLots.values.toList();
  }

  Future<List<Lot>> addAll({required List<Lot> lots}) async {
    _mappedLots.addAll({for (var lot in lots) lot.id: lot});

    return lots;
  }

  @override
  Future<Lot> delete({required Lot data}) async {
    final removedLot = _mappedLots.remove(data.id);

    if (removedLot != null) {
      printd('successfully removed lot');
    } else {
      printd('Lot already removed');
    }

    return data;
  }

  @override
  Future<Lot> get({required String id}) async {
    final data = _mappedLots[id];

    if (data == null) {
      return Future.error(LotNotFoundException());
    }

    return data;
  }

  @override
  Future<Lot> update({required Lot data}) async {
    return add(data: data);
  }

  Lot? searchLot({
    required String blockNo,
    required String lotNo,
  }) {
    return _mappedLots.values.firstWhereOrNull(
      (lot) => lot.blockNo == blockNo && lot.lotNo == lotNo,
    );
  }
}
