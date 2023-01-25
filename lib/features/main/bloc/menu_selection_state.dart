part of 'menu_selection_cubit.dart';

@immutable
abstract class MenuSelectionState {}

class MenuSelectionInitial extends MenuSelectionState {}

class MenuPageSelected extends MenuSelectionState {
  MenuPageSelected({ this.page = 0});
  final int page;
}
