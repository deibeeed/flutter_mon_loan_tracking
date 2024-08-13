part of 'add_loan_screen.dart';

Widget buildSmallScreenBody({
  required BuildContext context,
  required PagingController<int, LoanSchedule> pagingController,
  required GlobalKey<FormBuilderState> formKey,
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
  return FormBuilder(
    key: formKey,
    child: ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BlocBuilder<LoanBloc, LoanState>(
                buildWhen: (previous, current) => current is LoanSuccessState,
                builder: (context, state) {
                  return FormBuilderDateTimePicker(
                    name: 'date',
                    inputType: InputType.date,
                    decoration: const InputDecoration(
                      label: Text('Date'),
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.required(
                          errorText: 'Please enter date',
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 32,
              ),
              FormBuilderSearchableDropdown<User>(
                name: 'last_name',
                asyncItems: userBloc.searchCustomer,
                itemAsString: (user) => user.lastName,
                onChanged: (user) {
                  if (user != null) {
                    formKey.currentState?.fields['first_name']
                        ?.didChange(user.firstName);
                    loanBloc.selectUser(user: user);
                  }
                },
                decoration: const InputDecoration(
                  label: Text('Last name'),
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose(
                  [
                    FormBuilderValidators.required(
                        errorText: 'Please enter last name'),
                  ],
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              FormBuilderTextField(
                name: 'first_name',
                enabled: false,
                decoration: const InputDecoration(
                  label: Text('First name'),
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose(
                  [
                    FormBuilderValidators.required(
                        errorText: 'Please enter first name'),
                  ],
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'amount',
                      decoration: const InputDecoration(
                        label: Text('Loan amount'),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]*[.]?[0-9]*'),
                        ),
                      ],
                      valueTransformer: (amt) {
                        if (amt == null) {
                          return null;
                        }

                        return double.parse(amt);
                      },
                      validator: FormBuilderValidators.compose(
                        [
                          FormBuilderValidators.required(
                              errorText: 'Please enter loan amount'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 32,
                  ),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'term',
                      decoration: const InputDecoration(
                        label: Text('Term (In months)'),
                        border: OutlineInputBorder(),
                      ),
                      valueTransformer: (term) {
                        if (term == null) {
                          return null;
                        }

                        return int.parse(term);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                      ],
                      validator: FormBuilderValidators.compose(
                        [
                          FormBuilderValidators.required(
                            errorText: 'Please enter term',),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState?.saveAndValidate() ?? false) {
                        loanBloc.calculateLoan(
                          monthsToPay: formKey.currentState!.value['term'] as int,
                          date: formKey.currentState!.value['date'] as DateTime,
                          amount: formKey.currentState!.value['amount'] as double,
                        );
                      }
                    },
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
                        const Text('Loan principal:'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Term (in months):'),
                        Text('${formKey.currentState!.value['term'] as int} months'),
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
            onPressed: () {
              if (formKey.currentState?.saveAndValidate() ?? false) {
                loanBloc.addLoan(
                  monthsToPay: formKey.currentState!.value['term'] as int,
                  date: formKey.currentState!.value['date'] as DateTime,
                  amount: formKey.currentState!.value['amount'] as double,
                );
              }
            },
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
    ),
  );
}
