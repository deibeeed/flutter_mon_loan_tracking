import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
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
    on(_handleAddUserEvent);
    getAllUsers();
  }

  final UserRepository userRepository;

  final AuthenticationService authenticationService;

  final AddressRepository addressRepository;

  final BeneficiariesRepository beneficiaryRepository;

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

  User? tempUser;

  User? tempUserSpouse;

  Address? tempUserAddress;

  EmploymentDetails? tempUserEmploymentDetails;

  EmploymentDetails? tempUserSpouseEmploymentDetails;

  List<Beneficiary> tempUserBeneficiaries = [];

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
    tempUser = null;
    tempUserSpouse = null;
    tempUserEmploymentDetails = null;
    tempUserBeneficiaries = [];
    tempUserAddress = null;
    tempUserSpouseEmploymentDetails = null;
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

  // used by user details screen
  // TODO: remove this function when user details screen is updated with the new form
  void selectCivilStatus({required CivilStatus? civilStatus}) {
    _selectedCivilStatus = civilStatus;

    if (civilStatus != null) {
      emit(SelectedCivilStatusState(civilStatus: civilStatus));
    }
  }

  void selectCivilStatus2({required CivilStatus? civilStatus}) {
    _selectedCivilStatus = civilStatus;

    if (civilStatus != null) {
      tempUser?.civilStatus = civilStatus;

      if (civilStatus == CivilStatus.married) {
        initializeSpouse();
      } else {
        removeSpouse();
      }
    }
  }

  void initializeAddUser() {
    tempUser = User.createBlank();
    initializeAddedUserAddress();
    initializeBeneficiaries();
    emit(UpdateUiState());
  }

  void initializeSpouse() {
    tempUserSpouse = User.createBlank();
    tempUserSpouse?.civilStatus = CivilStatus.married;
    emit(UpdateUiState());
  }

  void removeSpouse() {
    removeAddedUserSpouseEmploymentDetails();
    tempUserSpouse = null;
    emit(UpdateUiState(removeFieldsThatStartsWithKey: 'spouse'));
  }

  void initializeAddedUserEmploymentDetails() {
    tempUserEmploymentDetails = EmploymentDetails.createBlank();
    emit(UpdateUiState());
  }

  void removeAddedUserEmploymentDetails() {
    tempUserEmploymentDetails = null;
    emit(UpdateUiState(removeFieldsThatStartsWithKey: 'ed'));
  }

  void initializeAddedUserSpouseEmploymentDetails() {
    tempUserSpouseEmploymentDetails = EmploymentDetails.createBlank();
    emit(UpdateUiState());
  }

  void removeAddedUserSpouseEmploymentDetails() {
    tempUserSpouseEmploymentDetails = null;
    // emit(UpdateUiState());
  }

  void initializeBeneficiaries() {
    tempUserBeneficiaries.clear();
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
    tempUserBeneficiaries.add(Beneficiary(
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
    tempUserBeneficiaries.remove(beneficiary);
    emit(
      UpdateUiState(),
    );
  }

  void initializeAddedUserAddress() {
    tempUserAddress = Address.createBlank();
  }

  void removeAddedUserAddress() {
    tempUserAddress = null;
  }

  void addUser({required Map<String,
      FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>>?
  fields}) {
    final values = fields?.map((key, value) => MapEntry(key, value.value));

    if (values == null) {
      emit(UserErrorState(message: 'Please enter user values'));
      return;
    }

    add(AddUserEvent(values: values));
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

  Future<void> _handleAddUserEvent(AddUserEvent event,
      Emitter<UserState> emit,) async {
    try {
      emit(UserLoadingState(isLoading: true));
      final values = event.values;

      if (tempUser == null) {
        throw Exception('User is not initialized. Please reload page');
      }

      if (tempUser!.civilStatus == CivilStatus.married &&
          tempUserSpouse == null) {
        throw Exception(
            'Spouse not initialized. Please choose civil status correctly');
      }

      if (tempUserAddress == null) {
        throw Exception('Please provide address');
      }

      /// NOTE: we will only be checking a couple of fields as
      /// fields being required is already handled by the UI.
      final email = values['email'] as String?;
      if (email == null || email.isEmpty) {
        throw Exception('Please supply email address');
      }

      final userId = await authenticationService.register(
        email: email,
        password: email,
      );

      if (userId == null) {
        throw Exception('Cannot register user');
      }

      tempUser = User.updateId(id: userId, user: tempUser!);
      final addedUser = await userRepository.add(data: tempUser!);
      tempUserAddress!.userId = userId;
      final addedUserAddress =
      await addressRepository.add(data: tempUserAddress!);
      if (tempUserEmploymentDetails != null) {
        tempUserEmploymentDetails!.userId = userId;
        final addedUserEmploymentDetails = await employmentDetailsRepository
            .add(data: tempUserEmploymentDetails!);
      }

      for (var beneficiary in tempUserBeneficiaries) {
        beneficiary.parentId = userId;
        await beneficiaryRepository.add(data: beneficiary);
      }

      if (addedUser.civilStatus == CivilStatus.married) {
        final addedUserSpouse = await userRepository.add(data: tempUserSpouse!);
        if (tempUserSpouseEmploymentDetails != null) {
          tempUserSpouseEmploymentDetails!.userId = addedUserSpouse.id;
          await employmentDetailsRepository.add(
              data: tempUserSpouseEmploymentDetails!);
        }
        // update spouseId of user
        addedUser.spouseId = addedUserSpouse.id;
        await userRepository.update(data: addedUser);
      }
      _filteredUsers.add(addedUser);
      // refresh
      getAllUsers();
      emit(UserLoadingState());
      emit(
          UserSuccessState(user: tempUser, message: 'Successfully added user'));
      await Future.delayed(Duration(seconds: 1));
      emit(CloseScreenState());
    } catch (err) {
      printd(err);
      emit(UserLoadingState());
      emit(UserErrorState(
          message: 'Something went wrong while adding user: $err'));
    }
  }

  Future<void> _handleUpdateUserEvent(UpdateUserEvent event,
      Emitter<UserState> emit,) async {
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

  Future<void> _handleGetAllUsersEvent(GetAllUsersEvent event,
      Emitter<UserState> emit) async {
    try {
      emit(UserLoadingState(isLoading: true));
      final tmpUsers = await userRepository.all();
      final spouseIds = tmpUsers.where((user) => user.spouseId != null)
          .toList()
          .map((e) => e.spouseId!)
          .toList();
      _filteredUsers
        ..clear()
        ..addAll(tmpUsers.whereNot((user) => spouseIds.contains(user.id)));
      _customers = await userRepository.customers();
      emit(UserLoadingState());
      emit(UserSuccessState(message: 'Successfully loaded all users'));
    } catch (err) {
      printd(err);
    }
  }

  Future<void> _handleSearchUsersEvent(SearchUsersEvent event,
      Emitter<UserState> emit) async {
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

  Future<void> _handleGetUserEvent(GetUserEvent event,
      Emitter<UserState> emit) async {
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
