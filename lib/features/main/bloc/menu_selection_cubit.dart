import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'menu_selection_state.dart';

class MenuSelectionCubit extends Cubit<MenuSelectionState> {
  MenuSelectionCubit() : super(MenuSelectionInitial());

  void select({ required int page}) {
    emit(MenuPageSelected(page: page));
  }
}
