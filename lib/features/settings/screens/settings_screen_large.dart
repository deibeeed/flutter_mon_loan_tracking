part of 'settings_screen.dart';

Widget buildLargeScreenBody({
  required BuildContext context,
  required TextEditingController loanInterestRateController,
  required TextEditingController incidentalFeesRateController,
  required TextEditingController serviceFeeController,
  required TextEditingController lotCategoryNameController,
  required TextEditingController lotCategoryPricePerSqmController,
  required TextEditingController downPaymentRateController,
  required TextEditingController vatRateController,
  required TextEditingController vattableTCPController,
  required bool allowTextControllerUpdate,
}) {
  final settingsBloc = BlocProvider.of<SettingsBloc>(context);

  final screenSize = MediaQuery.of(context).size;
  final shortestSide = screenSize.shortestSide;
  var buttonPadding = const EdgeInsets.all(24);

  if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
    buttonPadding = const EdgeInsets.all(16);
  }

  return SingleChildScrollView(
    child: BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsSuccessState) {
          if (allowTextControllerUpdate) {
            loanInterestRateController.text =
                settingsBloc.settings.loanInterestRate.toString();
            incidentalFeesRateController.text =
                settingsBloc.settings.incidentalFeeRate.toString();
            serviceFeeController.text =
                settingsBloc.settings.serviceFee.toString();
            downPaymentRateController.text =
                settingsBloc.settings.downPaymentRate.toString();
            allowTextControllerUpdate = false;
            vatRateController.text = settingsBloc.settings.vatRate.toString();
            vattableTCPController.text =
                settingsBloc.settings.vattableTCP.toString();

            if (state.message != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message!)));
            }

            context.read<LoanBloc>().getSettings();
            context.read<LotBloc>().initialize();
          }
        } else if (state is SettingsErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is LoadingSettingsState) {
          if (state.isLoading) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const AlertDialog(
                    content: SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(),
                    ),
                  );
                });
          } else {
            try {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            } catch (err) {
              printd(err);
            }
          }
        } else if (state is LotCategorySelectedState) {
          lotCategoryNameController.text = state.category.name;
          lotCategoryPricePerSqmController.text =
              state.category.ratePerSquareMeter.toString();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenSize.width * 0.25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Loan interest rate'),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previousState, currentState) {
                        return currentState is SettingsSuccessState;
                      },
                      builder: (context, state) {
                        return Text(
                          '${settingsBloc.settings.loanInterestRate}%',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Incidental fee rate'),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previousState, currentState) {
                        return currentState is SettingsSuccessState;
                      },
                      builder: (context, state) {
                        return Text(
                          '${settingsBloc.settings.incidentalFeeRate}%',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Downpayment rate'),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previousState, currentState) {
                        return currentState is SettingsSuccessState;
                      },
                      builder: (context, state) {
                        return Text(
                          '${settingsBloc.settings.downPaymentRate}%',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('VAT rate'),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previousState, currentState) {
                        return currentState is SettingsSuccessState;
                      },
                      builder: (context, state) {
                        return Text(
                          '${settingsBloc.settings.vatRate}%',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('VAT-able Total Contract Price'),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previousState, currentState) {
                        return currentState is SettingsSuccessState;
                      },
                      builder: (context, state) {
                        return Text(
                          settingsBloc.settings.vattableTCP.toCurrency(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Service fee'),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previousState, currentState) {
                        return currentState is SettingsSuccessState;
                      },
                      builder: (context, state) {
                        return Text(
                          settingsBloc.settings.serviceFee.toCurrency(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lot categories'),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previousState, currentState) {
                        return currentState is SettingsSuccessState;
                      },
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var category
                                in settingsBloc.settings.lotCategories) ...[
                              Text(
                                '${category.name} @ ${category.ratePerSquareMeter.toCurrency()}',
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: screenSize.width * 0.35,
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: loanInterestRateController,
                  decoration: const InputDecoration(
                    label: Text('Loan interest rate'),
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    // Debounce(milliseconds: 500).run(() {
                    //   settingsBloc.updateSettings(
                    //     field: SettingField.loanInterestRate,
                    //     value: value,
                    //   );
                    // });
                    settingsBloc.updateSettings(
                      field: SettingField.loanInterestRate,
                      value: value,
                    );
                  },
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: incidentalFeesRateController,
                  decoration: const InputDecoration(
                    label: Text('Incidental fee rate'),
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) => settingsBloc.updateSettings(
                    field: SettingField.incidentalFeeRate,
                    value: value,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: downPaymentRateController,
                  decoration: const InputDecoration(
                    label: Text('Downpayment rate'),
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) => settingsBloc.updateSettings(
                    field: SettingField.downPayment,
                    value: value,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: vatRateController,
                  decoration: const InputDecoration(
                    label: Text('VAT rate'),
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) => settingsBloc.updateSettings(
                    field: SettingField.vatRate,
                    value: value,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: vattableTCPController,
                  decoration: const InputDecoration(
                    label: Text('VAT-able Total Contract Price'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^[0-9]*[.]?[0-9]*'),
                    ),
                  ],
                  onChanged: (value) => settingsBloc.updateSettings(
                    field: SettingField.vattableTCP,
                    value: value,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: serviceFeeController,
                  decoration: const InputDecoration(
                    label: Text('Service fee'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) => settingsBloc.updateSettings(
                    field: SettingField.serviceFee,
                    value: value,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<SettingsBloc, SettingsState>(
                        buildWhen: (previous, current) =>
                            current is SettingsSuccessState,
                        builder: (context, state) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  enabled: settingsBloc
                                          .selectedLotCategoryKeyToUpdate ==
                                      null,
                                  controller: lotCategoryNameController,
                                  decoration: const InputDecoration(
                                    label: Text('Lot categories'),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: lotCategoryPricePerSqmController,
                                  decoration: const InputDecoration(
                                    label: Text('Rate per square meter'),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      if (settingsBloc
                                              .selectedLotCategoryKeyToUpdate ==
                                          null) {
                                        settingsBloc.addLotCategory(
                                          name: lotCategoryNameController.text,
                                          ratePerSqm:
                                              lotCategoryPricePerSqmController
                                                  .text,
                                        );
                                      } else {
                                        settingsBloc.updateLotCategory(
                                          name: lotCategoryNameController.text,
                                          ratePerSqm:
                                              lotCategoryPricePerSqmController
                                                  .text,
                                        );
                                      }

                                      lotCategoryPricePerSqmController.text =
                                          '';
                                      lotCategoryNameController.text = '';
                                    },
                                    icon: settingsBloc
                                                .selectedLotCategoryKeyToUpdate ==
                                            null
                                        ? const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          )
                                        : SvgPicture.asset(
                                            'assets/icons/refresh.svg',
                                            width: 24,
                                            height: 24,
                                            color: Colors.white,
                                          ),
                                  )),
                            ],
                          );
                        }),
                    const SizedBox(
                      height: 16,
                    ),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen: (previousState, currentState) {
                        return currentState is SettingsSuccessState;
                      },
                      builder: (context, state) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (var category
                                in settingsBloc.settings.lotCategories)
                              RawChip(
                                tapEnabled: true,
                                padding: const EdgeInsets.only(
                                    left: 8, top: 8, bottom: 8, right: 16),
                                label: Text(
                                  '${category.name} @ ${category.ratePerSquareMeter.toCurrency()}',
                                ),
                                onPressed: () {
                                  printd('helllo');
                                  settingsBloc.selectLotCategory(
                                    category: category,
                                  );
                                },
                                onDeleted: () => settingsBloc.removeLotCategory(
                                    category: category),
                                deleteIcon: const Icon(Icons.cancel),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 56,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: settingsBloc.saveUpdatedSettings,
                        style: ElevatedButton.styleFrom(
                            padding: buttonPadding,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                        child: Text(
                          'Update settings',
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
          )
        ],
      ),
    ),
  );
}
