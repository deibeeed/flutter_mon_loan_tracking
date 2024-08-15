import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
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
    on(_handleGetAllUsersEvent);
    on(_handleSearchUsersEvent);
    on(_handleGetUserEvent);
    on(_handleUpdateUserEvent);
    on(_handleAddUserEvent);
    on(_handleRemoveBeneficiaryEvent);
    getAllUsers();
  }

  final UserRepository userRepository;

  final AuthenticationService authenticationService;

  final AddressRepository addressRepository;

  final BeneficiariesRepository beneficiaryRepository;

  final EmploymentDetailsRepository employmentDetailsRepository;

  final List<User> _filteredUsers = [];

  List<User> get filteredUsers => _filteredUsers;

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

  String? updateBeneficiaryId;

  void search({required String query}) {
    add(SearchUsersEvent(query: query));
  }

  void reset() {
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

  void selectCivilStatus2({required CivilStatus? civilStatus}) {
    // if (civilStatus != null) {
    //   tempUser?.civilStatus = civilStatus;
    //
    //   if (civilStatus == CivilStatus.married) {
    //     initializeSpouse();
    //   } else {
    //     removeSpouse();
    //   }
    // }
  }

  void initializeAddUser({String? withId}) {
    if (withId == null) {
      tempUser = User.createBlank();
      initializeAddedUserAddress();
      initializeBeneficiaries();
      emit(UpdateUiState());
      return;
    }

    printd('called');
    add(GetUserEvent(userId: withId));
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

  Future<void> addBeneficiary({
    required String name,
    required DateTime birthDate,
    required Gender gender,
    required String relationship,
  }) async {
    showBeneficiaryInputFields = false;
    if (updateBeneficiaryId == null) {
      tempUserBeneficiaries.add(Beneficiary(
        name: name,
        birthDate: birthDate.millisecondsSinceEpoch,
        relationship: relationship,
        gender: gender,
        parentId: '',
      ));
    } else if (updateBeneficiaryId != Constants.NO_ID) {
      final beneficiary = tempUserBeneficiaries
          .firstWhere((beneficiary) => beneficiary.id == updateBeneficiaryId);

      beneficiary
        ..name = name
        ..birthDate = birthDate.millisecondsSinceEpoch
        ..gender = gender
        ..relationship = relationship;
      updateBeneficiaryId = null;
    } else {
      return;
    }

    emit(
      RemoveUiState(
        removeFieldsThatStartsWithKey: 'beneficiary',
      ),
    );
    await Future.delayed(const Duration(milliseconds: 100));
    emit(UpdateUiState());
  }

  void removeBeneficiary({required Beneficiary beneficiary}) {
    if (beneficiary.id == Constants.NO_ID) {
      tempUserBeneficiaries.remove(beneficiary);
      emit(
        UpdateUiState(),
      );
    } else {
      add(RemoveBeneficiaryEvent(beneficiary: beneficiary));
    }
  }

  Future<void> updateBeneficiary({required Beneficiary beneficiary}) async {
    if (beneficiary.id == Constants.NO_ID) {
      return;
    }
    showBeneficiaryInputFields = true;

    emit(UpdateUiState());
    await Future.delayed(const Duration(milliseconds: 100));
    updateBeneficiaryId = beneficiary.id;
    final values = <String, dynamic>{};

    values['beneficiary_name'] = beneficiary.name;
    values['beneficiary_birthDate'] =
        DateTime.fromMillisecondsSinceEpoch(beneficiary.birthDate.toInt());
    values['beneficiary_gender'] = beneficiary.gender;
    values['beneficiary_relationship'] = beneficiary.relationship;
    emit(UpdateUiState(showValues: values));
  }

  void initializeAddedUserAddress() {
    tempUserAddress = Address.createBlank();
  }

  void removeAddedUserAddress() {
    tempUserAddress = null;
  }

  void addUser({
    required Map<String,
            FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>>?
        fields,
  }) {
    final values = fields?.map((key, value) => MapEntry(key, value.value));

    if (values == null) {
      emit(UserErrorState(message: 'Please enter user values'));
      return;
    }

    add(AddUserEvent(values: values));
  }

  void updateUser({
    required Map<String,
            FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>>?
        fields,
  }) {
    final values = fields?.map((key, value) => MapEntry(key, value.value));

    if (values == null) {
      emit(UserErrorState(message: 'Please enter user values'));
      return;
    }

    add(UpdateUserEvent(values: values));
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

  Future<void> _handleUpdateUserEvent(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    // update user
    // update spouse
    // update address
    // update employment details
    // update spouse employment details
    // update beneficiaries
    try {
      if (tempUser == null) {
        emit(UserErrorState(message: 'User not selected'));
        return;
      }

      emit(UserLoadingState(isLoading: true));
      final updatedUser = await userRepository.update(data: tempUser!);

      if (tempUserSpouse != null) {
        final updatedSpouse =
            await userRepository.update(data: tempUserSpouse!);
      }

      if (tempUserEmploymentDetails != null) {
        final updatedUserEmploymentDetails = await employmentDetailsRepository
            .update(data: tempUserEmploymentDetails!);
      }

      if (tempUserSpouseEmploymentDetails != null) {
        final updatedUserSpouseEmploymentDetails =
            await employmentDetailsRepository.update(
                data: tempUserSpouseEmploymentDetails!);
      }

      if (tempUserAddress != null) {
        final updatedUserAddress =
            await addressRepository.update(data: tempUserAddress!);
      }

      for (final beneficiary in tempUserBeneficiaries) {
        if (beneficiary.id == Constants.NO_ID) {
          beneficiary.parentId = updatedUser.id;
          await beneficiaryRepository.add(data: beneficiary);
        } else {
          await beneficiaryRepository.update(data: beneficiary);
        }
      }
      getAllUsers();
      emit(UserLoadingState());
      emit(UserSuccessState(
          user: updatedUser, message: 'Successfully updated user'));
    } catch (err) {
      printd(err);
    }
  }

  Future<void> _handleGetAllUsersEvent(
      GetAllUsersEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoadingState(isLoading: true));
      final tmpUsers = await userRepository.all();
      // final spouseIds = tmpUsers
      //     .where((user) => user.spouseId != null)
      //     .toList()
      //     .map((e) => e.spouseId!)
      //     .toList();
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

  Future<List<User>> searchCustomer(String query) {
    return userRepository.customers().then((customers) {
      return customers
          .where((customer) => customer.lastName.toLowerCase().contains(query))
          .toList();
    });
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
                email?.contains(query) == true;
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
      printd('called2');
      emit(UserLoadingState(isLoading: true));
      // get user
      // get spouse
      // get address
      // get employment details
      // get spouse employment details
      // get beneficiaries
      tempUser = await userRepository.get(id: event.userId);
      emit(UpdateUiState());

      if (tempUser == null) {
        throw Exception('User not found');
      }

      try {
        tempUserEmploymentDetails =
            await employmentDetailsRepository.getByUserId(userId: tempUser!.id);
        emit(UpdateUiState());
      } catch (err) {
        printd('User employment details error: $err');
      }

      try {
        tempUserAddress =
            await addressRepository.getByUserId(userId: tempUser!.id);
        emit(UpdateUiState());
      } catch (err) {
        printd('User address error: $err');
      }

      try {
        tempUserBeneficiaries =
            await beneficiaryRepository.allFromParent(parentId: tempUser!.id);
        emit(UpdateUiState());
      } catch (err) {
        printd('User beneficiaries error: $err');
      }

      if (tempUser!.spouseId != null) {
        try {
          tempUserSpouse = await userRepository.get(id: tempUser!.spouseId!);
          emit(UpdateUiState());
        } catch (err) {
          printd('Spouse retrieve error: $err');
        }
        try {
          tempUserSpouseEmploymentDetails = await employmentDetailsRepository
              .getByUserId(userId: tempUserSpouse!.id);
          emit(UpdateUiState());
        } catch (err) {
          printd('Spouse employment details error: $err');
        }
      }

      emit(UserLoadingState());
      emit(UserSuccessState(message: 'Successfully retrieved user'));
      emit(UpdateUiState());
    } catch (err) {
      printd(err);
      emit(UserLoadingState());
      emit(UserErrorState(message: 'Something went wrong while getting user'));
    }
  }

  Future<void> _handleRemoveBeneficiaryEvent(
    RemoveBeneficiaryEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoadingState(isLoading: true));
      final removedBeneficiary =
          await beneficiaryRepository.delete(data: event.beneficiary);
      tempUserBeneficiaries.remove(removedBeneficiary);

      emit(UpdateUiState());
      emit(UserLoadingState());
      emit(UserSuccessState(message: 'Successfully removed beneficiary'));
    } catch (err) {
      printd(err);
      emit(UserLoadingState());
      emit(UserErrorState(
          message: 'Something went wrong while removing beneficiary: $err'));
    }
  }
}
