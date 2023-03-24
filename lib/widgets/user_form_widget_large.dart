import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/civil_status_types.dart';
import 'package:flutter_mon_loan_tracking/models/employment_details.dart';
import 'package:flutter_mon_loan_tracking/models/gender.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

Widget buildLargeScreenUserForm({
  required BuildContext context,
  required GlobalKey<FormBuilderState> formKey,
  bool isUpdate = false,
}) {
  final userBloc = BlocProvider.of<UserBloc>(context);
  final screenSize = MediaQuery.of(context).size;
  final shortestSide = screenSize.shortestSide;
  var buttonPadding = const EdgeInsets.all(24);

  if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
    buttonPadding = const EdgeInsets.all(16);
  }

  return SingleChildScrollView(
    child: FormBuilder(
      key: formKey,
      clearValueOnUnregister: true,
      child: BlocBuilder<UserBloc, UserState>(
          buildWhen: (previous, current) => current is UpdateUiState,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userBloc.tempUser != null)
                  _buildLargeScreenUserBlock(
                    context: context,
                    formKey: formKey,
                    user: userBloc.tempUser!,
                    employmentDetails: userBloc.tempUserEmploymentDetails,
                  ),
                if (userBloc.tempUserSpouse != null) ...[
                  const SizedBox(
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spouse details',
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  _buildLargeScreenUserBlock(
                    context: context,
                    formKey: formKey,
                    user: userBloc.tempUserSpouse!,
                    employmentDetails: userBloc.tempUserSpouseEmploymentDetails,
                    isSpouse: true,
                  ),
                ],
                if (userBloc.tempUser != null) ...[
                  _buildLargeScreenBeneficiaryBlock(
                    context: context,
                    userBloc: userBloc,
                    formKey: formKey,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  if (!isUpdate)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                userBloc.addUser(
                                    fields: formKey.currentState?.fields);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                padding: buttonPadding,
                                backgroundColor:
                                Theme.of(context).colorScheme.primary),
                            child: Text(
                              'Add User',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.apply(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                ],

              ],
            );
          }),
    ),
  );
}

Widget _buildLargeScreenUserBlock({
  required BuildContext context,
  required GlobalKey<FormBuilderState> formKey,
  required User user,
  EmploymentDetails? employmentDetails,
  bool isSpouse = false,
}) {
  final userBloc = BlocProvider.of<UserBloc>(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!isSpouse) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'General information',
              style: Theme.of(context).textTheme.titleLarge,
            )
          ],
        ),
        const SizedBox(
          height: 32,
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('User type'),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FormBuilderDropdown<UserType>(
                      name: 'userType',
                      initialValue: UserType.customer,
                      items: UserType.values.map((type) {
                        return DropdownMenuItem<UserType>(
                          value: type,
                          child: Text(type.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        user.type = value;
                      },
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Please select a user type',
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                name: !isSpouse ? 'nationality' : 'spouse_nationality',
                decoration: const InputDecoration(
                  label: Text('Nationality'),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  user.nationality = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a nationality',
                  ),
                      (value) => value?.isEmpty ?? false
                      ? 'Please enter a nationality'
                      : null,
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 32,
        ),
      ],
      Row(
        children: [
          Expanded(
            flex: 2,
            child: FormBuilderTextField(
              name: !isSpouse ? 'lastName' : 'spouse_lastName',
              decoration: const InputDecoration(
                label: Text('Last name'),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value == null || value.isEmpty) {
                  return;
                }

                user.lastName = value;
              },
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Please enter a last name',
                ),
                    (value) =>
                value?.isEmpty ?? false ? 'Please enter a last name' : null,
              ]),
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            flex: 2,
            child: FormBuilderTextField(
              name: !isSpouse ? 'firstName' : 'spouse_firstName',
              decoration: const InputDecoration(
                label: Text('First name'),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value == null || value.isEmpty) {
                  return;
                }

                user.firstName = value;
              },
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Please enter a first name',
                ),
                    (value) => value?.isEmpty ?? false
                    ? 'Please enter a first name'
                    : null,
              ]),
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            flex: 2,
            child: FormBuilderTextField(
              name: !isSpouse ? 'middleName' : 'spouse_middleName',
              decoration: const InputDecoration(
                label: Text('Middle name'),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => user.middleName = value,
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          if (!isSpouse)
            Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Civil status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    FormBuilderDropdown<CivilStatus>(
                      name: 'civilStatus',
                      initialValue: CivilStatus.single,
                      items: CivilStatus.values.map((type) {
                        return DropdownMenuItem<CivilStatus>(
                          value: type,
                          child: Text(type.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        userBloc.selectCivilStatus2(civilStatus: value);
                      },
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Please select a civil status',
                        ),
                      ]),
                    ),
                  ],
                )),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 8,
                ),
                FormBuilderDropdown<Gender>(
                  name: !isSpouse ? 'gender' : 'spouse_gender',
                  initialValue: Gender.male,
                  items: Gender.values.map((type) {
                    return DropdownMenuItem<Gender>(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    user.gender = value;
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: 'Please select a gender',
                    ),
                  ]),
                ),
              ],
            ),
          )
        ],
      ),
      const SizedBox(
        height: 32,
      ),
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'birthDate' : 'spouse_birthDate',
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate:
                  DateTime.now().subtract(const Duration(days: 365 * 100)),
                  lastDate: DateTime.now(),
                ).then((date) {
                  printd('date is $date');
                  if (date == null) {
                    return;
                  }
                  final dateStr = Constants.defaultDateFormat.format(date);
                  if (!isSpouse) {
                    formKey.currentState?.fields['birthDate']
                        ?.didChange(dateStr);
                  } else {
                    formKey.currentState?.fields['spouse_birthDate']
                        ?.didChange(dateStr);
                  }
                  user.birthDate = dateStr;
                });
              },
              decoration: const InputDecoration(
                label: Text('Birthdate'),
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Please select a birth date',
                ),
                    (value) => value?.isEmpty ?? false
                    ? 'Please select a birth date'
                    : null,
              ]),
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'birthPlace' : 'spouse_birthPlace',
              decoration: const InputDecoration(
                label: Text('Birth place'),
                border: OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => user.birthPlace = value,
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'weight' : 'spouse_weight',
              decoration: const InputDecoration(
                label: Text('Weight (Kg)'),
                suffixText: 'Kg',
                border: OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
              onChanged: (value) {
                if (value == null || value.isEmpty) {
                  return;
                }

                user.weight = num.parse(value);
              },
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'height' : 'spouse_height',
              decoration: const InputDecoration(
                label: Text('Height (cm)'),
                suffixText: 'cm',
                border: OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
              onChanged: (value) {
                if (value == null || value.isEmpty) {
                  return;
                }

                user.height = num.parse(value);
              },
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 32,
      ),
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'tinNo' : 'spouse_tinNo',
              decoration: const InputDecoration(
                label: Text('TIN number'),
                border: OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
              onChanged: (value) => user.tinNo = value,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Please enter a TIN number',
                ),
                    (value) => value?.isEmpty ?? false
                    ? 'Please enter a TIN number'
                    : null,
              ]),
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'sssNo' : 'spouse_sssNo',
              decoration: const InputDecoration(
                label: Text('SSS number'),
                border: OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
              onChanged: (value) => user.sssNo = value,
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'philHealthNo' : 'spouse_philHealthNo',
              decoration: const InputDecoration(
                label: Text('PhilHealth number'),
                border: OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
              onChanged: (value) => user.philHealthNo = value,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 32,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            !isSpouse ? 'Contact details' : 'Spouse Contact details',
            style: Theme.of(context).textTheme.titleLarge,
          )
        ],
      ),
      const SizedBox(
        height: 32,
      ),
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'mobileNo' : 'spouse_mobileNo',
              decoration: const InputDecoration(
                label: Text('Mobile number'),
                border: OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
              onChanged: (value) {
                if (value == null || value.isEmpty) {
                  return;
                }

                user.mobileNumber = value;
              },
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Please enter a mobile number',
                ),
                    (value) => value?.isEmpty ?? false
                    ? 'Please enter a mobile number'
                    : null,
              ]),
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'telNo' : 'spouse_telNo',
              decoration: const InputDecoration(
                label: Text('Telephone number'),
                border: OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
              onChanged: (value) => user.telNo = value,
            ),
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: FormBuilderTextField(
              name: !isSpouse ? 'email' : 'spouse_email',
              decoration: const InputDecoration(
                label: Text('Email'),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value == null || value.isEmpty) {
                  return;
                }

                user.email = value;
              },
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                    errorText: 'Please enter an email'),
                FormBuilderValidators.email(
                    errorText: 'Please enter a valid email'),
                    (value) =>
                value?.isEmpty ?? false ? 'Please enter an email' : null,
              ]),
            ),
          ),
          const SizedBox(
            width: 32,
          ),
        ],
      ),
      if (!isSpouse) ...[
        const SizedBox(
          height: 32,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Address Details',
              style: Theme.of(context).textTheme.titleLarge,
            )
          ],
        ),
        const SizedBox(
          height: 32,
        ),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'houseNo',
                decoration: const InputDecoration(
                  label: Text('House number'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  userBloc.tempUserAddress?.houseNo = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a house number',
                  ),
                      (value) => value?.isEmpty ?? false
                      ? 'Please enter a house number'
                      : null,
                ]),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                name: 'street',
                decoration: const InputDecoration(
                  label: Text('Street'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  userBloc.tempUserAddress?.street = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a street',
                  ),
                      (value) =>
                  value?.isEmpty ?? false ? 'Please enter a street' : null,
                ]),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                name: 'barangay',
                decoration: const InputDecoration(
                  label: Text('Barangay'),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  userBloc.tempUserAddress?.brgy = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a barangay',
                  ),
                      (value) => value?.isEmpty ?? false
                      ? 'Please enter a barangay'
                      : null,
                ]),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                name: 'zone',
                decoration: const InputDecoration(
                  label: Text('Zone'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  userBloc.tempUserAddress?.zone = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a zone',
                  ),
                      (value) =>
                  value?.isEmpty ?? false ? 'Please enter a zone' : null,
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 32,
        ),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'city',
                decoration: const InputDecoration(
                  label: Text('Municipality / City'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  userBloc.tempUserAddress?.city = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a municipality or city',
                  ),
                      (value) => value?.isEmpty ?? false
                      ? 'Please enter a municipality or city'
                      : null,
                ]),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                name: 'province',
                decoration: const InputDecoration(
                  label: Text('Province'),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  userBloc.tempUserAddress?.province = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a province',
                  ),
                      (value) => value?.isEmpty ?? false
                      ? 'Please enter a province'
                      : null,
                ]),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                name: 'zipCode',
                decoration: const InputDecoration(
                  label: Text('Zip code'),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  userBloc.tempUserAddress?.zipCode = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a zip code',
                  ),
                      (value) => value?.isEmpty ?? false
                      ? 'Please enter a zip code'
                      : null,
                ]),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                enabled: false,
                initialValue: 'Philippines',
                name: 'country',
                decoration: const InputDecoration(
                  label: Text('Country'),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  userBloc.tempUserAddress?.country = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a country',
                  ),
                      (value) =>
                  value?.isEmpty ?? false ? 'Please enter a country' : null,
                ]),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(
        height: 32,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              if (!isSpouse) {
                if (userBloc.tempUserEmploymentDetails == null) {
                  userBloc.initializeAddedUserEmploymentDetails();
                } else {
                  userBloc.removeAddedUserEmploymentDetails();
                }
              } else {
                if (userBloc.tempUserSpouseEmploymentDetails == null) {
                  userBloc.initializeAddedUserSpouseEmploymentDetails();
                } else {
                  userBloc.removeAddedUserSpouseEmploymentDetails();
                }
              }
            },
            child: Text(
              !isSpouse
                  ? '${userBloc.tempUserEmploymentDetails != null ? "Remove" : "Add"} employment details'
                  : '${userBloc.tempUserSpouseEmploymentDetails != null ? "Remove" : "Add"} employment details',
            ),
          ),
        ],
      ),
      if (!isSpouse && userBloc.tempUserEmploymentDetails != null ||
          isSpouse && userBloc.tempUserSpouseEmploymentDetails != null) ...[
        const SizedBox(
          height: 32,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              !isSpouse ? 'Employment details' : 'Spouse Employment details',
              style: Theme.of(context).textTheme.titleLarge,
            )
          ],
        ),
        const SizedBox(
          height: 32,
        ),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: !isSpouse ? 'ed_companyName' : 'spouse_ed_companyName',
                decoration: const InputDecoration(
                  label: Text('Company name'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  employmentDetails?.companyName = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter a company name',
                  ),
                      (value) => value?.isEmpty ?? false
                      ? 'Please enter a company name'
                      : null,
                ]),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                name: !isSpouse
                    ? 'ed_natureOfBusiness'
                    : 'spouse_ed_natureOfBusiness',
                decoration: const InputDecoration(
                  label: Text('Nature of business'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  employmentDetails?.natureOfBusiness = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter nature of business',
                  ),
                      (value) => value?.isEmpty ?? false
                      ? 'Please enter nature of business'
                      : null,
                ]),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                name: !isSpouse ? 'ed_position' : 'spouse_ed_position',
                decoration: const InputDecoration(
                  label: Text('Position'),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  employmentDetails?.position = value;
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter position',
                  ),
                      (value) =>
                  value?.isEmpty ?? false ? 'Please enter position' : null,
                ]),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderTextField(
                name: !isSpouse
                    ? 'ed_yearsOfEmployment'
                    : 'spouse_ed_yearsOfEmployment',
                decoration: const InputDecoration(
                  label: Text('Years of employment'),
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                ],
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  employmentDetails?.years = num.parse(value);
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter years of employment',
                  ),
                      (value) => value?.isEmpty ?? false
                      ? 'Please enter years of employment'
                      : null,
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 32,
        ),
        FormBuilderTextField(
          name: !isSpouse ? 'ed_companyAddress' : 'spouse_ed_companyAddress',
          decoration: const InputDecoration(
            label: Text('Company address'),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            if (value == null || value.isEmpty) {
              return;
            }

            employmentDetails?.address = value;
          },
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Please enter a company address',
            ),
                (value) => value?.isEmpty ?? false
                ? 'Please enter a company address'
                : null,
          ]),
        )
      ],
    ],
  );
}

Widget _buildLargeScreenBeneficiaryBlock({
  required BuildContext context,
  required UserBloc userBloc,
  required GlobalKey<FormBuilderState> formKey,
}) {
  return Column(
    children: [
      const SizedBox(
        height: 32,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Beneficiaries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ElevatedButton(
            onPressed: userBloc.showBeneficiary,
            child: const Text(
              'Add',
            ),
          )
        ],
      ),
      const SizedBox(
        height: 32,
      ),
      ...userBloc.tempUserBeneficiaries.mapIndexed((index, beneficiary) {
        return Row(
          children: [
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Beneficiary ${index + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        IconButton(
                          onPressed: () =>
                              userBloc.removeBeneficiary(beneficiary: beneficiary),
                          icon: Icon(
                            Icons.remove_circle_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 32,
                    ),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Name: ',
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                  text: beneficiary.name,
                                  style: Theme.of(context).textTheme.bodyMedium)
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Birthdate: ',
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                  text: beneficiary.birthDate.toDefaultDate(),
                                  style: Theme.of(context).textTheme.bodyMedium)
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Gender: ',
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                  text: beneficiary.gender.name,
                                  style: Theme.of(context).textTheme.bodyMedium)
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Relationship: ',
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                  text: beneficiary.relationship,
                                  style: Theme.of(context).textTheme.bodyMedium)
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ))
          ],
        );
      }).toList(),
      if (userBloc.showBeneficiaryInputFields) ...[
        const SizedBox(
          height: 32,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'beneficiary_name',
                    decoration: const InputDecoration(
                      label: Text('Beneficiary'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Please enter beneficiary name',
                      ),
                          (value) => value?.isEmpty ?? false
                          ? 'Please enter beneficiary name'
                          : null,
                    ]),
                  ),
                ),
                const SizedBox(
                  width: 32,
                ),
                Expanded(
                  child: FormBuilderDateTimePicker(
                    name: 'beneficiary_birthDate',
                    format: Constants.defaultDateFormat,
                    inputType: InputType.date,
                    decoration: const InputDecoration(
                      label: Text('Birthdate'),
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Please select beneficiary birth date',
                      ),
                    ]),
                  ),
                ),
                const SizedBox(
                  width: 32,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gender',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      FormBuilderDropdown<Gender>(
                        name: 'beneficiary_gender',
                        initialValue: Gender.male,
                        items: Gender.values.map((type) {
                          return DropdownMenuItem<Gender>(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Please select beneficiary gender',
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 32,
                ),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'beneficiary_relationship',
                    decoration: const InputDecoration(
                      label: Text('Relationship'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Please enter a beneficiary relationship',
                      ),
                          (value) => value?.isEmpty ?? false
                          ? 'Please enter a beneficiary relationship'
                          : null,
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    userBloc.addBeneficiary(
                        name: formKey.currentState?.fields['beneficiary_name']
                            ?.value as String,
                        birthDate: formKey
                            .currentState
                            ?.fields['beneficiary_birthDate']
                            ?.value as DateTime,
                        gender: formKey.currentState
                            ?.fields['beneficiary_gender']?.value as Gender,
                        relationship: formKey
                            .currentState
                            ?.fields['beneficiary_relationship']
                            ?.value as String);
                  },
                  child: const Text(
                    'Add Beneficiary',
                  ),
                )
              ],
            ),
          ],
        )
      ],
    ],
  );
}