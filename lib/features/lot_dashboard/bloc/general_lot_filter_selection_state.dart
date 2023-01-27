part of 'general_lot_filter_selection_cubit.dart';

@immutable
abstract class GeneralLotFilterSelectionState {}

class GeneralFilterSelectionInitial extends GeneralLotFilterSelectionState {}

class FilterSelectedState extends GeneralLotFilterSelectionState {
  FilterSelectedState({ this.position = 0});
  final int position;
}
