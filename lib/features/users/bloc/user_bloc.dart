import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_mon_loan_tracking/models/civil_status_types.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({
    required this.userRepository,
  }) : super(UserInitial()) {
    // on<UserEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on(_handleAddUserEvent);
    on(_handleGetAllUsersEvent);
    getAllUsers();
  }

  final List<User> _users = [];

  List<User> get users => _users;

  final UserRepository userRepository;

  void addUser({
    required String lastName,
    required String firstName,
    required String birthDate,
    required String civilStatus,
    required String mobileNumber,
    required String email,
    String? password,
    String? confirmPassword,
  }) {
    add(
      AddUserEvent(
        firstName: firstName,
        lastName: lastName,
        email: email,
        birthDate: birthDate,
        civilStatus: civilStatus,
        mobileNumber: mobileNumber,
        type: UserType.customer,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );
  }

  void getAllUsers() {
    add(GetAllUsersEvent());
  }

  Future<void> _handleAddUserEvent(
    AddUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoadingState(isLoading: true));
      final tmpUser = User(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        birthDate: event.birthDate,
        civilStatus: CivilStatus.single,
        mobileNumber: event.mobileNumber,
      );
      final addedUser = await userRepository.add(data: tmpUser);
      _users.add(addedUser);
      emit(UserLoadingState());
      emit(UserSuccessState(user: addedUser));
    } catch (err) {
      printd(err);
    }
  }

  Future<void> _handleGetAllUsersEvent(GetAllUsersEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoadingState(isLoading: true));
      final tmpUsers = await userRepository.all();
      _users.clear();
      _users.addAll(tmpUsers);
      emit(UserLoadingState());
    } catch (err) {
      printd(err);
    }
  }
}
