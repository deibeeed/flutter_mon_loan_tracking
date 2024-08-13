part of 'add_loan_screen.dart';

Widget buildSmallScreenBody({
  required BuildContext context,
  required LoanBloc loanBloc,
  required TextEditingController firstNameController,
  required TextEditingController lastNameController,
  required TextEditingController tcpController,
  required TextEditingController loanDurationController,
  required TextEditingController dateController,
  required PagingController<int, LoanSchedule> pagingController,
}) {
  final loanBloc = BlocProvider.of<LoanBloc>(context);
  final userBloc = BlocProvider.of<UserBloc>(context);
  final screenSize = MediaQuery.of(context).size;
  final shortestSide = screenSize.shortestSide;
  var buttonPadding = const EdgeInsets.all(24);
  var computationDetailsWidth = screenSize.width * 0.2;

  if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
    buttonPadding = const EdgeInsets.all(16);
    computationDetailsWidth = screenSize.width * 0.3;
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

  if (appBarHeight > Constants.maxAppBarHeight) {
    appBarHeight = Constants.maxAppBarHeight;
  }

  var isLargeScreenBreakpoint = false;

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
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BlocBuilder<LoanBloc, LoanState>(
              buildWhen: (previous, current) => current is LoanSuccessState,
              builder: (context, state) {
                printd('updated');
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
                        dateController.text =
                            Constants.defaultDateFormat.format(date);
                        loanBloc.selectDate(date: date);
                      }
                    });
                  },
                  controller: dateController,
                  decoration: const InputDecoration(
                    label: Text('Date'),
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 32,
            ),
            Autocomplete(
              optionsBuilder: (value) => userBloc.customers.where(
                (user) => user.lastName.toLowerCase().contains(
                      value.text.toLowerCase(),
                    ),
              ),
              displayStringForOption: (user) => user.completeName,
              onSelected: (user) => loanBloc.selectUser(user: user),
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onFieldSubmitted: (value) => onFieldSubmitted(),
                  decoration: const InputDecoration(
                    label: Text('Last name'),
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 32,
            ),
            TextFormField(
              controller: firstNameController,
              enabled: false,
              decoration: const InputDecoration(
                label: Text('First name'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => loanBloc.calculateLoan(
                    monthsToPay: loanDurationController.text,
                    date: dateController.text,
                    amount: tcpController.text,
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: buttonPadding,
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  child: Text(
                    'Calculate loan',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.apply(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 32,
      ),
      const Divider(
        thickness: 1.5,
      ),
      const SizedBox(
        height: 16,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text(
          'Computation',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      const SizedBox(
        height: 16,
      ),
      BlocBuilder<LoanBloc, LoanState>(
          buildWhen: (previous, current) => current is LoanSuccessState,
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total contract price:'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Loan duration:'),
                      Text(
                          '${loanDurationController.text} years to pay (${loanBloc.yearsToMonths(years: loanDurationController.text)} mos.)'),
                    ],
                  ),

                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly due:'),
                      Text(
                        loanBloc.monthlyAmortization.toCurrency(),
                        style: Theme.of(context).textTheme.titleLarge?.apply(
                              fontWeightDelta: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      const SizedBox(
        height: 32,
      ),
      const Divider(
        thickness: 1.5,
      ),
      const SizedBox(
        height: 32,
      ),
      Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Loan schedule',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton(
                onPressed: () {
                  var loan = loanBloc.selectedLoan;

                  if (loan == null) {
                    return;
                  }

                  PdfGenerator.generatePdf(
                    schedules: loanBloc.clientLoanSchedules,
                    loan: loan,
                  );
                },
                child: Text(
                  'Print',
                  style: Theme.of(context).textTheme.labelLarge,
                ))
          ],
        ),
      ),
      const SizedBox(
        height: 32,
      ),
      BlocBuilder<LoanBloc, LoanState>(
        buildWhen: (previous, current) {
          return current is LoanSuccessState;
        },
        builder: (context, state) {
          if (!isLargeScreenBreakpoint) {
            return buildDashboardTable(
              context: context,
              loanBloc: loanBloc,
              pagingController: pagingController,
              isSmallScreen: true,
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: buildDashboardTable(
                context: context,
                loanBloc: loanBloc,
                pagingController: pagingController,
                isSmallScreen: true),
          );
        },
      ),
      const SizedBox(
        height: 32,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: ElevatedButton(
          onPressed: () => loanBloc.addLoan(
            yearsToPay: loanDurationController.text,
            amount: tcpController.text,
            date: dateController.text,
          ),
          style: ElevatedButton.styleFrom(
              padding: buttonPadding,
              backgroundColor: Theme.of(context).colorScheme.primary),
          child: Text(
            'Add loan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.apply(color: Colors.white),
          ),
        ),
      ),
      const SizedBox(
        height: 32,
      ),
    ],
  );
}
