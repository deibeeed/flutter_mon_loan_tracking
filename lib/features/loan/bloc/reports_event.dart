part of 'reports_bloc.dart';

sealed class ReportsEvent {
  const ReportsEvent();
}

final class GenerateReportsEvent extends ReportsEvent {
  @override
  List<Object?> get props => [];
}
