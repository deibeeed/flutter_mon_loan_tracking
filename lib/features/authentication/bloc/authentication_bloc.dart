import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/exceptions/user_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/services/authentication_service.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required this.authenticationService,
    required this.usersRepository,
  }) : super(AuthenticationInitial()) {
    // on<AuthenticationEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on(_handleLogin);
  }

  final AuthenticationService authenticationService;
  final UserRepository usersRepository;

  void login({required String email, required String password}) {
    add(LoginEvent(email: email, password: password));
  }

  Future<void> _handleLogin(
    LoginEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      emit(const LoginLoadingState(isLoading: true));
      final userId = await authenticationService.login(
        email: event.email,
        password: event.password,
      );

      if (userId == null) {
        emit(const LoginLoadingState());
        emit(const LoginErrorState(message: 'UserId not found'));
      }

      final user = await usersRepository.get(id: userId!);
      emit(const LoginLoadingState());
      emit(
        LoginSuccessState(
          message: 'Welcome ${user.completeName}',
          user: user,
        ),
      );
    } on UserNotFoundException catch (err) {
      printd(err);
    } catch(err) {
      emit(const LoginLoadingState());
    }
  }
}
