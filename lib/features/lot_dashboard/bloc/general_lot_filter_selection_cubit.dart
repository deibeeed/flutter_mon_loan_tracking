import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'general_lot_filter_selection_state.dart';

class GeneralLotFilterSelectionCubit extends Cubit<GeneralLotFilterSelectionState> {
  GeneralLotFilterSelectionCubit() : super(GeneralFilterSelectionInitial());

  void select({ required int position }) {
    emit(FilterSelectedState(position: position));
  }
}
