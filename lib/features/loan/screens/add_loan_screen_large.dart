part of 'add_loan_screen.dart';

Widget buildLargeScreenBody({
  required BuildContext context,
  required PagingController<int, LoanSchedule> pagingController,
  required GlobalKey<FormBuilderState> formKey,
}) {
  final horizontalScrollController = ScrollController();
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
        const SizedBox(
          height: 8,
        ),
        BlocBuilder<LoanBloc, LoanState>(
          buildWhen: (previous, current) => current is LoanSuccessState,
          builder: (context, state) {
            return FormBuilderDateTimePicker(
              name: 'date',
              initialValue: DateTime.now(),
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
          compareFn: (u1, u2) {
            return u1 != u2;
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

                  print('transformer called');

                  return int.parse(term);
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                validator: FormBuilderValidators.compose(
                  [
                    FormBuilderValidators.required(
                      errorText: 'Please enter term',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 32,
            ),
            Expanded(
              child: FormBuilderDropdown(
                name: 'payment_frequency',
                decoration: const InputDecoration(
                  label: Text('Payment frequency'),
                  border: OutlineInputBorder(),
                ),
                // keyboardType: TextInputType.number,
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                // ],
                validator: FormBuilderValidators.compose(
                  [
                    FormBuilderValidators.required(
                      errorText: 'Please enter payment frequency',
                    ),
                  ],
                ),
                items: PaymentFrequency.values.map((item) {
                  return DropdownMenuItem<PaymentFrequency>(
                    value: item,
                    child: Text(item.label),
                  );
                }).toList(),
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
                    paymentFrequency: formKey.currentState!
                        .value['payment_frequency'] as PaymentFrequency,
                    withUser: true,
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
        const SizedBox(
          height: 32,
        ),
        const Divider(
          thickness: 1.5,
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          children: [
            Text(
              'Computation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        BlocBuilder<LoanBloc, LoanState>(
            buildWhen: (previous, current) => current is LoanSuccessState,
            builder: (context, state) {
              final term = formKey.currentState!.instantValue['term'] ?? 0;
              var amount = formKey.currentState!.instantValue['amount'];
              num previousLoanBalance = 0;
              var loanPrincipal = 0.toCurrency();

              if (amount != null) {
                if (amount.runtimeType == double) {
                  amount = (amount as double).toCurrency();
                } else if (amount.runtimeType == int) {
                  amount = (amount as int).toCurrency();
                } else if (amount.runtimeType == String) {
                  amount = double.parse(amount as String).toCurrency();
                }
              } else {
                amount = 0.0.toCurrency();
              }

              if (state is LoanSuccessState &&
                  state.data != null &&
                  state.data is Loan) {
                final loan = state.data as Loan;
                previousLoanBalance = loan.previousLoanBalance ?? 0;
                loanPrincipal =
                    (Constants.defaultCurrencyFormat.parse(amount.toString()) -
                            previousLoanBalance)
                        .toCurrency();
              }

              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: computationDetailsWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Start date:'),
                              Text(DateTime.now().toDefaultDate()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Loan amount:'),
                              Text('$amount'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Previous loan balance:'),
                              Text(previousLoanBalance.toCurrency()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Loan principal:'),
                              Text(loanPrincipal),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Term (in months):'),
                              Text('$term months'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Payment frequency:'),
                              Text((formKey.currentState!
                                              .instantValue['payment_frequency']
                                          as PaymentFrequency?)
                                      ?.label ??
                                  ''),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: screenSize.width * 0.2,
                      child: Column(
                        children: [
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Monthly due:',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.apply(
                                      fontWeightDelta: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary
                                          .withOpacity(0.8),
                                    ),
                              ),
                              Text(
                                loanBloc.monthlyAmortization.toCurrency(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.apply(
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
        Row(
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
              ),
            )
          ],
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
              );
            }

            return Scrollbar(
              controller: horizontalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: buildDashboardTable(
                  context: context,
                  loanBloc: loanBloc,
                  pagingController: pagingController,
                  finiteSize: loanBloc.clientLoanSchedules.isNotEmpty,
                ),
              ),
            );
          },
        ),
        const SizedBox(
          height: 32,
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    // var monthsToPay = formKey.currentState!.value['term'];
                    //
                    // if (monthsToPay.runtimeType == String) {
                    //   monthsToPay = int.parse(monthsToPay as String);
                    // } else {
                    //   monthsToPay = monthsToPay as int;
                    // }

                    loanBloc.addLoan(
                      monthsToPay: formKey.currentState!.value['term'] as int,
                      date: formKey.currentState!.value['date'] as DateTime,
                      amount: formKey.currentState!.value['amount'] as double,
                      paymentFrequency: formKey.currentState!
                          .value['payment_frequency'] as PaymentFrequency,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: buttonPadding,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Add loan',
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
  );
}
