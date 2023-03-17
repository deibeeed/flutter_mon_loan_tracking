part of 'add_user_screen.dart';

Widget buildSmallScreenBody({
  required BuildContext context,
  required TextEditingController lastNameController,
  required TextEditingController firstNameController,
  required TextEditingController mobileNumberController,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required TextEditingController confirmPasswordController,
  required TextEditingController birthDateController,
  required TextEditingController middleNameController,
  required TextEditingController birthPlaceController,
  required TextEditingController nationalityController,
  required TextEditingController heightController,
  required TextEditingController weightController,
  required TextEditingController childrenCountController,
  required TextEditingController tinNoController,
  required TextEditingController sssNoController,
  required TextEditingController philHealthController,
  required TextEditingController telNoController,
}) {
  final userBloc = BlocProvider.of<UserBloc>(context);
  final screenSize = MediaQuery.of(context).size;
  final shortestSide = screenSize.shortestSide;
  var buttonPadding = const EdgeInsets.all(24);

  if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
    buttonPadding = const EdgeInsets.all(16);
  }

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              var type = UserType.customer;

              if (state is SelectedUserTypeState) {
                type = state.type;
              }

              return DropdownButton<UserType>(
                value: type,
                items: UserType.values.map((type) {
                  return DropdownMenuItem<UserType>(
                    value: type,
                    child: Text(type.value),
                  );
                }).toList(),
                onChanged: (value) => userBloc.selectUserType(type: value),
              );
            },
          ),
          TextFormField(
            controller: lastNameController,
            decoration: const InputDecoration(
                label: Text('Last name'), border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: firstNameController,
            decoration: const InputDecoration(
                label: Text('First name'), border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 32,
          ),
          Text(
            'Civil status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                var dropdownValue = CivilStatus.values.first;

                if (state is SelectedCivilStatusState) {
                  dropdownValue = state.civilStatus;
                }

                return DropdownButton<CivilStatus>(
                  value: dropdownValue,
                  items: CivilStatus.values.map((category) {
                    return DropdownMenuItem<CivilStatus>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) => userBloc.selectCivilStatus(
                    civilStatus: value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          BlocBuilder<UserBloc, UserState>(
            buildWhen: (previous, current) => current is UserSuccessState,
            builder: (context, state) {
              return TextFormField(
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:
                    DateTime.now().subtract(Duration(days: 365 * 100)),
                    lastDate: DateTime.now(),
                  ).then((date) {
                    printd('date is $date');
                    if (date != null) {
                      birthDateController.text =
                          Constants.defaultDateFormat.format(date);
                      userBloc.selectDate(date: date);
                    }
                  });
                },
                controller: birthDateController,
                decoration: const InputDecoration(
                  label: Text('Birthdate'),
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),
          const SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: mobileNumberController,
            decoration: const InputDecoration(
              label: Text('Mobile number'),
              border: OutlineInputBorder(),
            ),
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              label: Text('Email'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              label: Text('Password'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              label: Text('Confirm password'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => userBloc.addUser(
                      lastName: lastNameController.text,
                      firstName: firstNameController.text,
                      birthDate: birthDateController.text,
                      mobileNumber: mobileNumberController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      confirmPassword: confirmPasswordController.text),
                  style: ElevatedButton.styleFrom(
                      padding: buttonPadding,
                      backgroundColor: Theme.of(context).colorScheme.primary),
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
      ),
    ),
  );
}