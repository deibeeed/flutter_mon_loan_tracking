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
    initialize();
  }

  final LotRepository lotRepository;
  final SettingsRepository settingsRepository;
  List<String> _lotCategories = [];

  List<String> get lotCategories => _lotCategories;
  String? _selectedLotCategory;

  final Map<String, List<Lot>> _groupedLots = {};

  Map<String, List<Lot>> get groupedLots => _groupedLots;

  void addLot({
    required String lotCategory,
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
        lotCategory: lotCategory,
        area: num.parse(area),
        blockLotNos: blockLotNos,
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

  List<List<Lot>> chunkedLots({ required List<Lot> lots}) {
    lots.sortBy((element) => element.lotNo);
    final len = lots.length;
    const size = 4;
    final chunks = <List<Lot>>[];

    for(var i = 0; i< len; i+= size)
    {
      final end = (i+size<len)?i+size:len;
      chunks.add(lots.sublist(i,end));
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
      _groupedLots.addAll(groupBy(lots, (p0) => p0.blockNo));
      emit(LotLoadingState());
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
      emit(DismissLotState());
    } catch (err) {
      printd(err);
      emit(LotLoadingState());
      emit(LotErrorState(message: 'Something went wrong when adding lot'));
    }
  }

  Future<void> _handleUpdateLotEvent(
      UpdateLotEvent event, Emitter<LotState> emit) async {
    try {
      emit(LotLoadingState(isLoading: true));

      final lot = await lotRepository.update(data: event.lot);

      emit(LotLoadingState());
      emit(LotSuccessState(lot: lot, message: 'Successfully updated lot'));
    } catch (err) {
      emit(LotErrorState(message: 'Something went wrong when updating lot'));
      printd(err);
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
}
