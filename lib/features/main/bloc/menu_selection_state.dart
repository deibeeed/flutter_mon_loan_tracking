part of 'menu_selection_cubit.dart';

@immutable
abstract class MenuSelectionState extends Equatable {}

class MenuSelectionInitial extends MenuSelectionState {
  @override
  List<Object?> get props => [Random().nextInt(999)];
}

class MenuPageSelected extends MenuSelectionState {
  MenuPageSelected({ this.page = 0});
  final int page;

  @override
  List<Object?> get props => [Random().nextInt(999)];
}
