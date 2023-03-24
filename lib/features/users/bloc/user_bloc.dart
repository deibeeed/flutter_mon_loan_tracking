import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mon_loan_tracking/models/address.dart';
import 'package:flutter_mon_loan_tracking/models/beneficiary.dart';
import 'package:flutter_mon_loan_tracking/models/civil_status_types.dart';
import 'package:flutter_mon_loan_tracking/models/employment_details.dart';
import 'package:flutter_mon_loan_tracking/models/gender.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/repositories/address_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/beneficiary_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/employment_details_repository.dart';
import 'package:flutter_mon_loan_tracking/repositories/users_repository.dart';
import 'package:flutter_mon_loan_tracking/services/authentication_service.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({
    required this.userRepository,
    required this.authenticationService,
    required this.addressRepository,
    required this.beneficiaryRepository,
    required this.employmentDetailsRepository,
  }) : super(UserInitial()) {
    // on<UserEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on(_handleGetAllUsersEvent);
    on(_handleSearchUsersEvent);
    on(_handleGetUserEvent);
    on(_handleUpdateUserEvent);
    on(_handleAddUserEvent2);
    getAllUsers();
  }

  final UserRepository userRepository;

  final AuthenticationService authenticationService;

  final AddressRepository addressRepository;

  final BeneficiaryRepository beneficiaryRepository;

  final EmploymentDetailsRepository employmentDetailsRepository;

  final List<User> _filteredUsers = [];

  List<User> get filteredUsers => _filteredUsers;

  User? _selectedUser;

  User? get selectedUser => _selectedUser;

  UserType? _selectedType;

  CivilStatus? _selectedCivilStatus;

  CivilStatus? get selectedCivilStatus => _selectedCivilStatus;

  Gender? _selectedGender;

  Gender? get selectedGender => _selectedGender;

  Map<String, User> get mappedUsers => userRepository.mappedUsers;

  List<User> _customers = [];

  List<User> get customers => _customers;

  User? addedUser;

  User? addedUserSpouse;

  Address? addedUserAddress;

  EmploymentDetails? addedUserEmploymentDetails;

  EmploymentDetails? addedUserSpouseEmploymentDetails;

  List<Beneficiary> addedUserBeneficiaries = [];

  bool showBeneficiaryInputFields = false;

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
    _selectedCivilStatus = null;
    _selectedType = null;
    _selectedGender = null;
    addedUser = null;
    addedUserSpouse = null;
    addedUserEmploymentDetails = null;
    addedUserBeneficiaries = [];
    addedUserAddress = null;
    addedUserSpouseEmploymentDetails = null;
  }

  void selectDate({required DateTime date}) {
    emit(UserSuccessState(message: 'Successfully selected date'));
  }

  void selectUserType({required UserType? type}) {
    _selectedType = type;

    if (type != null) {
      emit(SelectedUserTypeState(type: type));
    }
  }

  void selectCivilStatus({required CivilStatus? civilStatus}) {
    _selectedCivilStatus = civilStatus;

    if (civilStatus != null) {
      emit(SelectedCivilStatusState(civilStatus: civilStatus));
    }
  }

  void selectCivilStatus2({required CivilStatus? civilStatus}) {
    _selectedCivilStatus = civilStatus;

    if (civilStatus != null) {
      addedUser?.civilStatus = civilStatus;

      if (civilStatus == CivilStatus.married) {
        initializeSpouse();
      } else {
        removeSpouse();
      }
    }
  }

  void initializeAddUser() {
    addedUser = User.createBlank();
    initializeAddedUserAddress();
    initializeBeneficiaries();
    emit(UpdateUiState());
  }

  void initializeSpouse() {
    addedUserSpouse = User.createBlank();
    addedUserSpouse?.civilStatus = CivilStatus.married;
    emit(UpdateUiState());
  }

  void removeSpouse() {
    removeAddedUserSpouseEmploymentDetails();
    addedUserSpouse = null;
    emit(UpdateUiState(removeFieldsThatStartsWithKey: 'spouse'));
  }

  void initializeAddedUserEmploymentDetails() {
    addedUserEmploymentDetails = EmploymentDetails.createBlank();
    emit(UpdateUiState());
  }

  void removeAddedUserEmploymentDetails() {
    addedUserEmploymentDetails = null;
    emit(UpdateUiState(removeFieldsThatStartsWithKey: 'ed'));
  }

  void initializeAddedUserSpouseEmploymentDetails() {
    addedUserSpouseEmploymentDetails = EmploymentDetails.createBlank();
    emit(UpdateUiState());
  }

  void removeAddedUserSpouseEmploymentDetails() {
    addedUserSpouseEmploymentDetails = null;
    // emit(UpdateUiState());
  }

  void initializeBeneficiaries() {
    addedUserBeneficiaries.clear();
  }

  void showBeneficiary() {
    showBeneficiaryInputFields = true;
    emit(UpdateUiState());
  }

  void addBeneficiary({
    required String name,
    required DateTime birthDate,
    required Gender gender,
    required String relationship,
  }) {
    showBeneficiaryInputFields = false;
    addedUserBeneficiaries.add(Beneficiary(
      name: name,
      birthDate: birthDate.millisecondsSinceEpoch,
      relationship: relationship,
      gender: gender,
      parentId: '',
    ));
    emit(
      RemoveUiState(
        removeFieldsThatStartsWithKey: 'beneficiary',
      ),
    );
    emit(UpdateUiState());
  }

  void removeBeneficiary({required Beneficiary beneficiary}) {
    addedUserBeneficiaries.remove(beneficiary);
    emit(
      UpdateUiState(),
    );
  }

  void initializeAddedUserAddress() {
    addedUserAddress = Address.createBlank();
  }

  void removeAddedUserAddress() {
    addedUserAddress = null;
  }

  void addUser2(
      {required Map<String,
              FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>>?
          fields}) {
    final values = fields?.map((key, value) => MapEntry(key, value.value));

    if (values == null) {
      emit(UserErrorState(message: 'Please enter user values'));
      return;
    }

    add(AddUserEvent2(values: values));
  }

  void updateUser({
    required String lastName,
    required String firstName,
    required String birthDate,
    required String mobileNumber,
    required String email,
  }) {
    if (_selectedCivilStatus == null) {
      emit(UserErrorState(message: 'Please select civil status'));
      return;
    }

    add(UpdateUserEvent(
      firstName: firstName,
      lastName: lastName,
      email: email,
      birthDate: birthDate,
      civilStatus: _selectedCivilStatus!,
      mobileNumber: mobileNumber,
    ));
  }

  void getAllUsers() {
    add(GetAllUsersEvent());
  }

  User? getLoggedInUser() {
    return userRepository.getLoggedInUser();
  }

  Future<void> _handleAddUserEvent2(
    AddUserEvent2 event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoadingState(isLoading: true));
      final values = event.values;

      if (addedUser == null) {
        throw Exception('User is not initialized. Please reload page');
      }

      if (addedUser!.civilStatus == CivilStatus.married &&
          addedUserSpouse == null) {
        throw Exception(
            'Spouse not initialized. Please choose civil status correctly');
      }

      /// NOTE: we will only be checking a couple of fields as
      /// fields being required is already handled by the UI.
      final email = values['email'] as String?;
      if (email == null || email.isEmpty) {
        throw Exception('Please supply email address');
      }

      final lastName = values['lastName'] as String?;
      final firstName = values['firstName'] as String?;

      if (lastName == null || firstName == null) {
        throw Exception('Please supply last name or first name');
      }

      // final userId = await authenticationService.register(
      //   email: email,
      //   password: email,
      // );
      //
      // if (userId == null) {
      //   throw Exception('Cannot register user');
      // }

      // final tmpAddedUser = User.updateId(id: userId, user: addedUser!);
      // final addedUser = await userRepository.add(data: tmpUser);
      // _filteredUsers.add(addedUser);
      // refresh
      // getAllUsers();
      emit(UserLoadingState());
      emit(UserSuccessState(
          user: addedUser, message: 'Successfully added user'));
      // await Future.delayed(Duration(seconds: 2));
      // emit(CloseScreenState());
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
      var civilStatus = event.civilStatus;

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
      _customers = await userRepository.customers();
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
      _selectedCivilStatus = _selectedUser!.civilStatus;
      emit(UserLoadingState());
      emit(UserSuccessState(message: 'Successfully retrieved user'));
    } catch (err) {
      printd(err);
      emit(UserLoadingState());
      emit(UserErrorState(message: 'Something went wrong while getting user'));
    }
  }
}
