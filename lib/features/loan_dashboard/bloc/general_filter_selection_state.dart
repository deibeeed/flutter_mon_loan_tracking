part of 'general_filter_selection_cubit.dart';

@immutable
abstract class GeneralFilterSelectionState {}

class GeneralFilterSelectionInitial extends GeneralFilterSelectionState {}

class FilterSelectedState extends GeneralFilterSelectionState {
  FilterSelectedState({ this.position = 0});
  final int position;
}
