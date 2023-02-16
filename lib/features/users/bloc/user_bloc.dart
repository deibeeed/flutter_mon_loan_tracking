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
    on(_handleSearchUsersEvent);
    getAllUsers();
  }

  // final List<User> _users = [];

  final List<User> _filteredUsers = [];

  List<User> get filteredUsers => _filteredUsers;

  final UserRepository userRepository;

  void search({required String query}) {
    add(SearchUsersEvent(query: query));
  }

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
      _filteredUsers.add(addedUser);
      emit(UserLoadingState());
      emit(UserSuccessState(
          user: addedUser, message: 'Successfully added user'));
    } catch (err) {
      printd(err);
    }
  }

  Future<void> _handleGetAllUsersEvent(
      GetAllUsersEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoadingState(isLoading: true));
      final tmpUsers = await userRepository.all();
      _filteredUsers
        ..clear()
        ..addAll(tmpUsers);
      emit(UserLoadingState());
      emit(UserSuccessState(message: 'Successfully loaded all users'));
    } catch (err) {
      printd(err);
    }
  }

  Future<void> _handleSearchUsersEvent(
      SearchUsersEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoadingState(isLoading: true));
      final query = event.query.toLowerCase();
      final users = await userRepository.allCache();

      if (query.isNotEmpty) {
        final filteredList = users.where(
              (user) {
            final lastName = user.lastName.toLowerCase();
            final firstName = user.firstName.toLowerCase();
            final email = user.email;

            return lastName.contains(query) ||
                firstName.contains(query) ||
                email.contains(query);
          },
        ).toList();
        _filteredUsers
          ..clear()
          ..addAll(filteredList);
      } else {
        _filteredUsers
          ..clear()
          ..addAll(users);
      }

      emit(UserLoadingState());
      emit(UserSuccessState(message: 'Successfully searched user'));
    } catch (err) {
      printd(err);
      emit(UserLoadingState());
      emit(
        UserErrorState(
          message: 'Something went wrong while searching for users',
        ),
      );
    }
  }
}
