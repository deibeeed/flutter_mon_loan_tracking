part of 'user_details_screen.dart';

Widget buildLargeScreenBody({
  required BuildContext context,
  String? userId,
  bool isProfile = false,
  required PagingController<int, LoanSchedule> pagingController,
  required GlobalKey<FormBuilderState> formKey,
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

  var appBarHeight = screenSize.height * 0.16;
  var isLargeScreenBreakpoint = false;

  if (appBarHeight > Constants.maxAppBarHeight) {
    appBarHeight = Constants.maxAppBarHeight;
  }

  if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
    isLargeScreenBreakpoint = true;
  }

  return ListView(
    children: [
      const SizedBox(
        height: 16,
      ),
      buildLargeScreenUserForm(
        context: context,
        formKey: formKey,
        isUpdate: true,
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
                onPressed: () =>
                    userBloc.updateUser(fields: formKey.currentState?.fields),
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
          Visibility(
              visible: isProfile,
              child: Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: authenticationBloc.logout,
                        style: ElevatedButton.styleFrom(
                            padding: buttonPadding,
                            backgroundColor:
                                Theme.of(context).colorScheme.error),
                        child: Text(
                          'Logout',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.apply(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userBloc.getLoggedInUser()?.type == UserType.admin &&
                  userBloc.getLoggedInUser()?.id != userId) ...[
                ElevatedButton(
                  onPressed: loanBloc.removeLoan,
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer),
                  child: Text(
                    'Remove',
                    style: Theme.of(context).textTheme.titleMedium?.apply(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                )
              ],
              ElevatedButton(
                  onPressed: () {
                    var user = userBloc.tempUser;
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
                    'Print',
                    style: Theme.of(context).textTheme.labelLarge,
                  )),
            ],
          )
        ],
      ),
      const SizedBox(
        height: 32,
      ),
      BlocBuilder<LoanBloc, LoanState>(
        buildWhen: (previous, current) {
          return current is LoanDisplaySummaryState ||
              current is LoanSuccessState;
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
