import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    // on<SplashEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on(_handleGoToEvent);
    _initTimer();
  }

  void _initTimer() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      add(SplashGoToEvent(goto: '/login'));
      timer.cancel();
    });
  }

  void _handleGoToEvent(SplashGoToEvent event, Emitter<SplashState> emit) {
    emit(SplashGoToState(goto: event.goto));
  }
}
