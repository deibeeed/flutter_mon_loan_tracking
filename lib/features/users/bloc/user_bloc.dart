import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_mon_loan_tracking/models/civil_status_types.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/services/authentication_service.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({
    required this.userRepository,
    required this.authenticationService,
  }) : super(UserInitial()) {
    // on<UserEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on(_handleAddUserEvent);
    on(_handleGetAllUsersEvent);
    on(_handleSearchUsersEvent);
    on(_handleGetUserEvent);
    on(_handleUpdateUserEvent);
    getAllUsers();
  }

  // final List<User> _users = [];

  final List<User> _filteredUsers = [];

  List<User> get filteredUsers => _filteredUsers;

  final UserRepository userRepository;

  final AuthenticationService authenticationService;

  User? _selectedUser;

  User? get selectedUser => _selectedUser;

  UserType? _selectedType;

  void search({required String query}) {
    add(SearchUsersEvent(query: query));
  }

  void selectUser({
    required String userId,
  }) {
    add(GetUserEvent(userId: userId));
  }

  void reset() {
    _selectedUser = null;
  }

  void selectUserType({required UserType? type}) {
    _selectedType = type;

    if (type != null) {
      emit(SelectedUserTypeState(type: type));
    }
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
    if (_selectedType == null) {
      emit(UserErrorState(message: 'Please select type'));
      return;
    }

    // for now, force email to become password
    add(
      AddUserEvent(
        firstName: firstName,
        lastName: lastName,
        email: email,
        birthDate: birthDate,
        civilStatus: civilStatus,
        mobileNumber: mobileNumber,
        type: _selectedType!,
        password: email,
        confirmPassword: email,
      ),
    );
  }

  void updateUser({
    required String lastName,
    required String firstName,
    required String birthDate,
    required String civilStatus,
    required String mobileNumber,
    required String email,
  }) {
    add(UpdateUserEvent(
      firstName: firstName,
      lastName: lastName,
      email: email,
      birthDate: birthDate,
      civilStatus: civilStatus,
      mobileNumber: mobileNumber,
    ));
  }

  void getAllUsers() {
    add(GetAllUsersEvent());
  }

  User? getLoggedInUser() {
    return userRepository.getLoggedInUser();
  }

  Future<void> _handleAddUserEvent(
    AddUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoadingState(isLoading: true));
      var civilStatus = CivilStatus.single;

      switch (event.civilStatus) {
        case 'divorced':
          civilStatus = CivilStatus.divorced;
          break;
        case 'married':
          civilStatus = CivilStatus.married;
          break;
      }

      final userId = await authenticationService.register(
        email: event.email,
        password: event.password,
      );

      if (userId == null) {
        throw Exception('Cannot register user');
      }

      var tmpUser = User(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        birthDate: event.birthDate,
        civilStatus: civilStatus,
        mobileNumber: event.mobileNumber,
        type: event.type,
      );
      tmpUser = User.updateId(id: userId, user: tmpUser);
      final addedUser = await userRepository.add(data: tmpUser);
      _filteredUsers.add(addedUser);
      // refresh
      getAllUsers();
      emit(UserLoadingState());
      emit(UserSuccessState(
          user: addedUser, message: 'Successfully added user'));
      await Future.delayed(Duration(seconds: 2));
      emit(CloseScreenState());
    } catch (err) {
      printd(err);
      emit(UserLoadingState());
      emit(UserErrorState(
          message: 'Something went wrong while adding user: $err'));
    }
  }

  Future<void> _handleUpdateUserEvent(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (_selectedUser == null) {
        emit(UserErrorState(message: 'User not selected'));
        return;
      }

      emit(UserLoadingState(isLoading: true));
      var civilStatus = CivilStatus.single;

      switch (event.civilStatus) {
        case 'divorced':
          civilStatus = CivilStatus.divorced;
          break;
        case 'married':
          civilStatus = CivilStatus.married;
          break;
      }

      var tmpUser = User(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        birthDate: event.birthDate,
        civilStatus: civilStatus,
        mobileNumber: event.mobileNumber,
      );
      tmpUser = User.updateId(id: _selectedUser!.id, user: tmpUser);
      final addedUser = await userRepository.update(data: tmpUser);
      _filteredUsers.add(addedUser);
      emit(UserLoadingState());
      emit(UserSuccessState(
          user: addedUser, message: 'Successfully updated user'));
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

  Future<void> _handleGetUserEvent(
      GetUserEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoadingState(isLoading: true));
      _selectedUser = await userRepository.get(id: event.userId);
      emit(UserLoadingState());
      emit(UserSuccessState(message: 'Successfully retrieved user'));
    } catch (err) {
      printd(err);
      emit(UserLoadingState());
      emit(UserErrorState(message: 'Something went wrong while getting user'));
    }
  }
}
