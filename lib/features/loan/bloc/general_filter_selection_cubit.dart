import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'general_filter_selection_state.dart';

class GeneralFilterSelectionCubit extends Cubit<GeneralFilterSelectionState> {
  GeneralFilterSelectionCubit() : super(GeneralFilterSelectionInitial());

  void select({ required int position }) {
    emit(FilterSelectedState(position: position));
  }
}
