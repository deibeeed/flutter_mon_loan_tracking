import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/models/lot.dart';
import 'package:flutter_mon_loan_tracking/repositories/lot_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/settings_repository.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

part 'lot_event.dart';

part 'lot_state.dart';

class LotBloc extends Bloc<LotEvent, LotState> {
  LotBloc({required this.lotRepository, required this.settingsRepository})
      : super(LotInitial()) {
    // on<LotEvent>((event, emit) {
    //   // TODO: implement event handler
    // });

    on(_handleInitializeEvent);
    on(_handleAddLotEvent);
    on(_handleUpdateLotEvent);
    on(_handleDeleteLotEvent);
    on(_handleSearchLotEvent);
    on(_handleFilterByAvailabilityEvent);
    initialize();
  }

  final LotRepository lotRepository;
  final SettingsRepository settingsRepository;
  List<String> _lotCategories = [];

  List<String> get lotCategories => _lotCategories;
  String? _selectedLotCategory;

  final Map<String, List<Lot>> _groupedLots = {};

  final Map<String, List<Lot>> _filteredGroupedLots = {};

  Map<String, List<Lot>> get filteredGroupedLots => _filteredGroupedLots;

  Lot? _selectedLot;

  Lot? get selectedLot => _selectedLot;

  void selectLot({required Lot lot}) {
    _selectedLot = lot;
    _selectedLotCategory = lot.lotCategory;
    emit(LotSuccessState(message: 'Successfully selected lot'));
  }

  void selectBlock({required String blockNo}) {
    emit(LotSuccessState(message: 'Successfully selected block'));
  }

  void search({required String query}) {
    add(SearchLotEvent(query: query));
  }

  void filter({required String filter}) {
    add(FilterByAvailabilityEvent(filter: filter));
  }

  void addLot({
    required String area,
    required String blockLotNos,
    required String description,
  }) {
    if (_selectedLotCategory == null) {
      printd('Select lot category first');
      return;
    }

    add(
      AddLotEvent(
        lotCategory: _selectedLotCategory!,
        area: num.parse(area),
        blockLotNos: blockLotNos,
        description: description,
      ),
    );
  }

  void updateLot({
    required String area,
    required String blockNo,
    required String lotNo,
    required String description,
  }) {
    if (_selectedLotCategory == null) {
      printd('Select lot category first');
      return;
    }

    add(
      UpdateLotEvent(
        lotCategory: _selectedLotCategory!,
        area: num.parse(area),
        blockNo: blockNo,
        lotNo: lotNo,
        description: description,
      ),
    );
  }

  void deleteLot({required Lot lot}) {
    add(DeleteLotEvent(lot: lot));
  }

  void initialize() {
    add(InitializeLotEvent());
  }

  void selectLotCategory({required String? lotCategory}) {
    _selectedLotCategory = lotCategory;
    emit(SelectedLotCategoryLotState(selectedLotCategory: lotCategory!));
  }

  List<List<Lot>> chunkedLots({required List<Lot> lots, int size = 4,}) {
    lots.sortBy((element) => element.lotNo);
    final len = lots.length;
    final chunks = <List<Lot>>[];

    for (var i = 0; i < len; i += size) {
      final end = (i + size < len) ? i + size : len;
      chunks.add(lots.sublist(i, end));
    }

    return chunks;
  }

  Future<void> _handleInitializeEvent(
    InitializeLotEvent event,
    Emitter<LotState> emit,
  ) async {
    try {
      emit(LotLoadingState(isLoading: true));
      final settings = await settingsRepository.all();
      _lotCategories
        ..clear()
        ..addAll(settings[0].lotCategories);
      _selectedLotCategory = _lotCategories.first;
      final lots = await lotRepository.all();
      final grouped = groupBy(lots, (p0) => p0.blockNo);
      _groupedLots.addAll(
        Map.fromEntries(
          grouped.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
        ),
      );
      _filteredGroupedLots.addAll(_groupedLots);
      emit(LotLoadingState());
      emit(LotSuccessState(message: 'successfully initialized lots'));
    } catch (err) {
      emit(LotErrorState(message: 'Something went wrong when initializing'));
    }
  }

  Future<void> _handleAddLotEvent(
      AddLotEvent event, Emitter<LotState> emit) async {
    try {
      if (_selectedLotCategory == null) {
        emit(LotErrorState(message: 'Please select lot category first'));
        return;
      }
      emit(LotLoadingState(isLoading: true));

      final blockLotNosSplit = event.blockLotNos.split(',');

      if (!blockLotNosSplit
          .every((element) => element.split(':').length == 2)) {
        emit(LotLoadingState());
        emit(
          LotErrorState(message: '1 or more Block or Lot does not have a pair'),
        );
        return;
      }

      final futureLots = blockLotNosSplit.map((blkLot) {
        final splitted = blkLot.split(':');
        final blockNo = splitted.first;
        final lotNo = splitted.last;
        return lotRepository.add(
          data: Lot.create(
            lotCategory: _selectedLotCategory!,
            blockNo: blockNo,
            lotNo: lotNo,
            description: event.description,
            area: event.area,
          ),
        );
      });

      await Future.wait(futureLots);

      emit(LotLoadingState());
      emit(AddLotSuccessState(message: 'Successfully added lot/s'));
      _selectedLotCategory = null;
      await Future.delayed(const Duration(seconds: 3));
      emit(CloseAddLotState());
    } catch (err) {
      printd(err);
      emit(LotLoadingState());
      emit(LotErrorState(message: 'Something went wrong when adding lot'));
    }
  }

  Future<void> _handleUpdateLotEvent(
      UpdateLotEvent event, Emitter<LotState> emit) async {
    try {
      if (_selectedLotCategory == null) {
        emit(LotErrorState(message: 'Please select lot category first'));
        return;
      }

      if (_selectedLot == null) {
        emit(LotErrorState(message: 'No lot has been selected'));
        return;
      }
      emit(LotLoadingState(isLoading: true));

      var tmpLot = Lot.create(
        lotCategory: event.lotCategory,
        blockNo: event.blockNo,
        lotNo: event.lotNo,
        description: event.description,
        area: event.area,
        reservedTo: _selectedLot!.reservedTo,
      );
      tmpLot = Lot.updateId(id: _selectedLot!.id, lot: tmpLot);
      final updatedLot = await lotRepository.update(data: tmpLot);

      emit(LotLoadingState());
      emit(AddLotSuccessState(message: 'Successfully updated lot'));
      _selectedLotCategory = null;
      await Future.delayed(const Duration(seconds: 3));
      emit(CloseAddLotState());
    } catch (err) {
      printd(err);
      emit(LotLoadingState());
      emit(LotErrorState(message: 'Something went wrong when adding lot'));
    }
  }

  Future<void> _handleDeleteLotEvent(
      DeleteLotEvent event, Emitter<LotState> emit) async {
    try {
      emit(LotLoadingState(isLoading: true));

      final lot = await lotRepository.delete(data: event.lot);

      emit(LotLoadingState());
      emit(LotSuccessState(lot: lot, message: 'Successfully deleted lot'));
    } catch (err) {
      emit(LotErrorState(message: 'Something went wrong when deleting lot'));
      printd(err);
    }
  }

  Future<void> _handleSearchLotEvent(
    SearchLotEvent event,
    Emitter<LotState> emit,
  ) async {
    try {
      emit(LotLoadingState(isLoading: true));
      final query = event.query;

      if (query.isNotEmpty) {
        final lots = await lotRepository.allCache();
        final filteredList = lots.where(
          (lot) {
            if (!query.contains(':')) {
              return lot.blockNo == query || lot.lotNo == query;
            }
            final combined = '${lot.blockNo}:${lot.lotNo}';

            return query == combined;
          },
        ).toList();

        final grouped = groupBy(filteredList, (p0) => p0.blockNo);
        final groupedFilteredList = Map.fromEntries(
          grouped.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
        );
        _filteredGroupedLots
          ..clear()
          ..addAll(groupedFilteredList);
      } else {
        _filteredGroupedLots
          ..clear()
          ..addAll(_groupedLots);
      }

      emit(LotLoadingState());
      emit(LotSuccessState(message: 'Successfully performed query'));
    } catch (err) {
      printd(err);
      emit(LotLoadingState());
      emit(LotErrorState(
          message: 'Something went wrong while searching for lot'));
    }
  }

  Future<void> _handleFilterByAvailabilityEvent(
      FilterByAvailabilityEvent event, Emitter<LotState> emit) async {
    try {
      emit(LotLoadingState(isLoading: true));
      final filter = event.filter.toLowerCase();
      final lots = await lotRepository.allCache();

      switch (filter) {
        case 'available':
          final filteredList = lots
              .where(
                (lot) => lot.reservedTo == null,
              )
              .toList();

          final grouped = groupBy(filteredList, (p0) => p0.blockNo);
          final groupedFilteredList = Map.fromEntries(
            grouped.entries.toList()
              ..sort((e1, e2) => e1.key.compareTo(e2.key)),
          );
          _filteredGroupedLots
            ..clear()
            ..addAll(groupedFilteredList);
          break;
        case 'unavailable':
          final filteredList = lots
              .where(
                (lot) => lot.reservedTo != null,
              )
              .toList();

          final grouped = groupBy(filteredList, (p0) => p0.blockNo);
          final groupedFilteredList = Map.fromEntries(
            grouped.entries.toList()
              ..sort((e1, e2) => e1.key.compareTo(e2.key)),
          );
          _filteredGroupedLots
            ..clear()
            ..addAll(groupedFilteredList);
          break;
        default:
          _filteredGroupedLots
            ..clear()
            ..addAll(_groupedLots);
      }

      emit(LotLoadingState());
      emit(LotSuccessState(
          message: 'Successfully filtered lots by availability'));
    } catch (err) {
      printd(err);
      emit(LotLoadingState());
      emit(LotErrorState(
        message: 'Something went wrong while filtering by availability',
      ));
    }
  }
}
