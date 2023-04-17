part of 'add_loan_screen.dart';

Widget buildSmallScreenBody({
  required BuildContext context,
  required LoanBloc loanBloc,
  required TextEditingController firstNameController,
  required TextEditingController lastNameController,
  required TextEditingController blockNoController,
  required TextEditingController lotNoController,
  required TextEditingController lotAreaController,
  required TextEditingController lotCategoryController,
  required TextEditingController pricePerSqmController,
  required TextEditingController tcpController,
  required TextEditingController loanDurationController,
  required TextEditingController downpaymentController,
  required TextEditingController discountController,
  required TextEditingController discountDescriptionController,
  required TextEditingController agentAssistedController,
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
            TextFormField(
              controller: agentAssistedController,
              decoration: const InputDecoration(
                label: Text('Assisting agent'),
                border: OutlineInputBorder(),
              ),
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
            BlocBuilder<LoanBloc, LoanState>(
                buildWhen: (previous, current) => current is LoanSuccessState,
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: blockNoController,
                        decoration: const InputDecoration(
                          label: Text('Block No.'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        ],
                        onChanged: (value) => loanBloc.setBlockAndLotNo(
                          type: 'blockNo',
                          no: value,
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        controller: lotNoController,
                        decoration: const InputDecoration(
                          label: Text('Lot no.'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        ],
                        onChanged: (value) => loanBloc.setBlockAndLotNo(
                          type: 'lotNo',
                          no: value,
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        controller: lotAreaController,
                        enabled: false,
                        decoration: const InputDecoration(
                          label: Text('Lot Area (sqm)'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        ],
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        controller: lotCategoryController,
                        enabled: false,
                        decoration: const InputDecoration(
                            label: Text('Lot category'),
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        controller: pricePerSqmController,
                        enabled: false,
                        decoration: const InputDecoration(
                          label: Text('Price / sqm'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        ],
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        controller: tcpController,
                        enabled: false,
                        decoration: const InputDecoration(
                          label: Text('Total contract price'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        ],
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        controller: loanDurationController,
                        decoration: const InputDecoration(
                          label: Text('Loan duration (Years)'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        ],
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        controller: downpaymentController,
                        decoration: const InputDecoration(
                          label: Text('Downpayment'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                        ],
                      ),
                    ],
                  );
                }),
            const SizedBox(
              height: 32,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: discountController,
                              decoration: const InputDecoration(
                                label: Text('Discount'),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp('[0-9.,]'),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 32,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: discountDescriptionController,
                              decoration: const InputDecoration(
                                label: Text('Description'),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      BlocBuilder<LoanBloc, LoanState>(
                          buildWhen: (previous, current) =>
                              current is LoanSuccessState,
                          builder: (context, state) {
                            return Row(
                              children: [
                                for (var i = 0;
                                    i < loanBloc.discounts.length;
                                    i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Chip(
                                      padding: const EdgeInsets.only(
                                          left: 8,
                                          top: 8,
                                          bottom: 8,
                                          right: 16),
                                      label: Text(
                                        'Less: ${loanBloc.discounts[i].description}: ${loanBloc.discounts[i].discount.toCurrency()}',
                                      ),
                                      onDeleted: () =>
                                          loanBloc.removeDiscount(position: i),
                                      deleteIcon: const Icon(Icons.cancel),
                                    ),
                                  )
                              ],
                            );
                          }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: () {
                  loanBloc.addDiscount(
                    discount: discountController.text,
                    description: discountDescriptionController.text,
                  );
                  discountController.text = '';
                  discountDescriptionController.text = '';
                },
                style: ElevatedButton.styleFrom(
                    padding: buttonPadding,
                    backgroundColor: Theme.of(context).colorScheme.primary),
                child: Text(
                  'Add discount',
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
            Row(
              children: [
                Text(
                  'Lot description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            BlocBuilder<LoanBloc, LoanState>(
              buildWhen: (previous, current) => current is LoanSuccessState,
              builder: (context, state) {
                String? description = '';

                if (loanBloc.selectedLot != null) {
                  description = loanBloc.selectedLot?.description;
                }

                return Text(description ?? '');
              },
            ),
            const SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => loanBloc.calculateLoan(
                      downPayment: downpaymentController.text,
                      yearsToPay: loanDurationController.text,
                      date: dateController.text),
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
                      const Text('Lot area:'),
                      Text(loanBloc.selectedLot?.description ?? ''),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price per sqm:'),
                      Builder(
                        builder: (context) {
                          final lot = loanBloc.selectedLot;
                          final settings = loanBloc.settings;

                          if (lot == null || settings == null) {
                            return Container();
                          }

                          final lotCategory = settings.lotCategories
                              .firstWhereOrNull((category) =>
                                  category.key == lot.lotCategoryKey);

                          return Text(
                              '${lotCategory?.ratePerSquareMeter.toCurrency() ?? 0.toCurrency()} per sqm');
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total contract price:'),
                      Text(loanBloc.computeTCP().toCurrency()),
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
                  ...loanBloc.discounts
                      .map(
                        (discount) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Less: ${discount.description}:'),
                            Text(
                              discount.discount.toCurrency(isDeduction: true),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add: Incidental fee:'),
                      Text(loanBloc.computeIncidentalFee().toCurrency()),
                    ],
                  ),
                  // TODO: uncomment if service fee is implemented
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text('Add: Service fee:'),
                  //     Text(loanBloc.getServiceFee().toCurrency()),
                  //   ],
                  // ),
                  if (loanBloc.getVatAmount() != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Add: VAT:'),
                        Text(loanBloc.getVatAmount()!.toCurrency()),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Outstanding balance:'),
                      Text(loanBloc.outstandingBalance.toCurrency()),
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
                  var lot = loanBloc.selectedLot;

                  if (loan == null || lot == null) {
                    return;
                  }

                  PdfGenerator.generatePdf(
                    schedules: loanBloc.clientLoanSchedules,
                    loan: loan,
                    lot: lot,
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
              isSmallScreen: true
            ),
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
            downPayment: downpaymentController.text,
            agentAssisted: agentAssistedController.text,
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
