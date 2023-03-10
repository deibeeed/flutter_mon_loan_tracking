import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/exceptions/user_not_found_exception.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/services/authentication_service.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    on(_handleLogoutEvent);
    on(_handleInitializeEvent);
    initialize();
  }

  final AuthenticationService authenticationService;
  final UserRepository usersRepository;

  final storage = FirebaseStorage.instance;

  String? _backgroundDownloadUrl;

  String? get backgroundDownloadUrl => _backgroundDownloadUrl;

  String? _lastLogin;

  String? get lastLogin => _lastLogin;

  List<String> _emails = [];

  List<String> get emails => _emails;

  void initialize() {
    add(InitializeEvent());
  }

  void selectEmail() {
    emit(UiEmitState());
  }

  void login({required String email, required String password}) {
    printd('email: $email, password: $password');
    add(LoginEvent(email: email, password: password));
  }

  void logout() {
    add(LogoutEvent());
  }

  bool isLoggedIn() {
    return authenticationService.isLoggedIn();
  }

  User? getLoggedInUser() {
    return usersRepository.getLoggedInUser();
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
        return;
      }

      final user = await usersRepository.get(id: userId);
      usersRepository.setLoggedInUser(user: user);
      final shared = await SharedPreferences.getInstance();
      await shared.setString('lastLogin', '${event.email}::${event.password}');
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

  Future<void> _handleLogoutEvent(LogoutEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(LoginLoadingState(isLoading: true));
      await authenticationService.logout();
      emit(LoginLoadingState());
      emit(LogoutSuccessState());
    } catch (err) {
      printd(err);
      emit(LoginLoadingState());
      emit(LoginErrorState(message: 'Something went wrong while logging out'));
    }
  }

  Future<void> _handleInitializeEvent(InitializeEvent event, Emitter<AuthenticationState> emit,) async {
    try {
      if (authenticationService.isLoggedIn()) {
        final user = await usersRepository.get(id: authenticationService.loggedInUser!.uid);
        usersRepository.setLoggedInUser(user: user);
        emit(LoginSuccessState(message: 'Welcome back ${user.firstName}', user: user));
      }

      final shared = await SharedPreferences.getInstance();
      _lastLogin = shared.getString('lastLogin');
      _emails
      ..clear()
      ..add(_lastLogin!.split('::')[0]);
    } catch (err) {
      printd(err);
    }
  }
}
