part of 'lot_bloc.dart';

@immutable
abstract class LotState {}

class LotInitial extends LotState {}

class LotSuccessState extends LotState {
  final Lot? lot;
  final String? message;

  LotSuccessState({ this.lot, this.message});

}

class LotErrorState extends LotState {
  final String message;

  LotErrorState({ required this.message });
}

class LotLoadingState extends LotState {
  final bool isLoading;
  final String? loadingMessage;

  LotLoadingState({ this.isLoading = false,  this.loadingMessage });
}


class SelectedLotCategoryLotState extends LotState {
  final String selectedLotCategory;

  SelectedLotCategoryLotState({ required this.selectedLotCategory});
}

class AddLotSuccessState extends LotState {
  final Lot? lot;
  final String? message;

  AddLotSuccessState({ this.lot, this.message});
}

class DismissLotState extends LotState {

}