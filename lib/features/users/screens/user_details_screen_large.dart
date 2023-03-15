part of 'user_details_screen.dart';

Widget buildLargeScreenBody({
  required BuildContext context,
  String? userId,
  bool isProfile = false,
  required TextEditingController lastNameController,
  required TextEditingController firstNameController,
  required TextEditingController mobileNumberController,
  required TextEditingController emailController,
  required TextEditingController civilStatusController,
  required TextEditingController passwordController,
  required TextEditingController confirmPasswordController,
  required TextEditingController birthDateController,
  required PagingController<int, LoanSchedule> pagingController,
}) {
  final horizontalScrollController = ScrollController();
  final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
  final loanBloc = BlocProvider.of<LoanBloc>(context);

  final userBloc = BlocProvider.of<UserBloc>(context);

  final screenSize = MediaQuery.of(context).size;
  final shortestSide = screenSize.shortestSide;
  var buttonPadding = const EdgeInsets.all(24);

  if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
    buttonPadding = const EdgeInsets.all(16);
  }

  final width = screenSize.width;
  final computedWidth = width * 0.88;
  var appBarHeight = screenSize.height * 0.16;
  var loginContainerRadius = Constants.defaultRadius;
  var loginContainerMarginTop = 64.0;
  var titleTextStyle = Theme.of(context).textTheme.displaySmall;
  var avatarTextStyle = Theme.of(context).textTheme.titleLarge;
  var avatarSize = 56.0;
  var contentPadding = const EdgeInsets.all(58);
  var appBarBottomPadding = 48.0;
  var isLargeScreenBreakpoint = false;

  if (appBarHeight > Constants.maxAppBarHeight) {
    appBarHeight = Constants.maxAppBarHeight;
  }

  if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
    loginContainerRadius = const Radius.circular(64);
    loginContainerMarginTop = 32;
    titleTextStyle = Theme.of(context).textTheme.headlineMedium;
    avatarTextStyle = Theme.of(context).textTheme.titleSmall;
    avatarSize = 48;
    contentPadding = const EdgeInsets.only(
      left: 32,
      right: 32,
      top: 16,
      bottom: 16,
    );
    appBarBottomPadding = 24;
    isLargeScreenBreakpoint = true;
  }

  return ListView(
    children: [
      const SizedBox(
        height: 16,
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
      Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Civil status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(
                height: 8,
              ),
              BlocBuilder<UserBloc, UserState>(
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
                        child: Text(category.value),
                      );
                    }).toList(),
                    onChanged: (value) => userBloc.selectCivilStatus(
                      civilStatus: value,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
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
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: TextFormField(
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
          ),
          const SizedBox(
            width: 32,
          ),
          Expanded(
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                label: Text('Email'),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 32,
      ),
      Row(
        children: [
          Visibility(
            visible: shouldShowUpdateButton(context: context, userId: userId),
            child: Expanded(
              child: ElevatedButton(
                onPressed: () => userBloc.updateUser(
                  lastName: lastNameController.text,
                  firstName: firstNameController.text,
                  birthDate: birthDateController.text,
                  mobileNumber: mobileNumberController.text,
                  email: emailController.text,
                ),
                style: ElevatedButton.styleFrom(
                    padding: buttonPadding,
                    backgroundColor: Theme.of(context).colorScheme.primary),
                child: Text(
                  'Update profile',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.apply(color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 32,
          ),
          Visibility(
              visible: isProfile,
              child: Expanded(
                child: ElevatedButton(
                  onPressed: authenticationBloc.logout,
                  style: ElevatedButton.styleFrom(
                      padding: buttonPadding,
                      backgroundColor: Theme.of(context).colorScheme.error),
                  child: Text(
                    'Logout',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.apply(color: Colors.white),
                  ),
                ),
              )),
        ],
      ),
      Visibility(
        visible: userBloc.getLoggedInUser()?.type == UserType.admin &&
            userBloc.getLoggedInUser()?.id != userId,
        child: Column(
          children: [
            const SizedBox(
              height: 32,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authenticationBloc.logout,
                style: ElevatedButton.styleFrom(
                    padding: buttonPadding,
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer),
                child: Text(
                  'Delete',
                  style: Theme.of(context).textTheme.titleMedium?.apply(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            )
          ],
        ),
      ),
      const SizedBox(
        height: 32,
      ),
      // const Divider(
      //   thickness: 1.5,
      // ),
      // const SizedBox(
      //   height: 16,
      // ),
      // Row(
      //   children: [
      //     Text(
      //       'Purchased lots',
      //       style: Theme.of(context).textTheme.titleLarge,
      //     ),
      //   ],
      // ),
      // const SizedBox(
      //   height: 16,
      // ),
      // Text('Some purchased lots here ???'),
      // const SizedBox(
      //   height: 32,
      // ),
      const Divider(
        thickness: 1.5,
      ),
      const SizedBox(
        height: 32,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Loan schedule',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ElevatedButton(
              onPressed: () {
                var user = userBloc.selectedUser;
                var loan = loanBloc.selectedLoan;
                var lot = loanBloc.selectedLot;

                if (user == null || loan == null || lot == null) {
                  return;
                }

                PdfGenerator.generatePdf(
                  user: user,
                  schedules: loanBloc.clientLoanSchedules,
                  loan: loan,
                  lot: lot,
                );
              },
              child: Text(
                'Generate PDF',
                style: Theme.of(context).textTheme.labelLarge,
              ))
        ],
      ),
      const SizedBox(
        height: 32,
      ),
      BlocBuilder<LoanBloc, LoanState>(
        buildWhen: (previous, current) {
          return current is LoanDisplaySummaryState;
        },
        builder: (context, state) {
          if (!isLargeScreenBreakpoint) {
            return buildDashboardTable(
              context: context,
              loanBloc: loanBloc,
              pagingController: pagingController,
              withStatus: true,
              userId: userId,
              loggedInUserType:
                  userBloc.getLoggedInUser()?.type ?? UserType.customer,
            );
          }

          return Scrollbar(
            controller: horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: horizontalScrollController,
              child: buildDashboardTable(
                context: context,
                loanBloc: loanBloc,
                pagingController: pagingController,
                withStatus: true,
                userId: userId,
                finiteSize: loanBloc.clientLoanSchedules.isNotEmpty,
                loggedInUserType:
                userBloc.getLoggedInUser()?.type ?? UserType.customer,
              ),
            ),
          );
        },
      ),
      const SizedBox(
        height: 32,
      ),
    ],
  );
}
