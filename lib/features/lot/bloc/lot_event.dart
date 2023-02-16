part of 'lot_bloc.dart';

@immutable
abstract class LotEvent {}

class AddLotEvent extends LotEvent {
  final String lotCategory;
  final num area;
  final String blockLotNos;
  final String description;

  AddLotEvent({
    required this.lotCategory,
    required this.area,
    required this.blockLotNos,
    required this.description,
  });
}

class UpdateLotEvent extends LotEvent {
  final Lot lot;

  UpdateLotEvent({required this.lot});
}

class DeleteLotEvent extends LotEvent {
  final Lot lot;

  DeleteLotEvent({required this.lot});
}

class InitializeLotEvent extends LotEvent { }

class SearchLotEvent extends LotEvent {
  final String query;

  SearchLotEvent({ required this.query });
}

class FilterByAvailabilityEvent extends LotEvent {
  final String filter;

  FilterByAvailabilityEvent({ required this.filter});
}
