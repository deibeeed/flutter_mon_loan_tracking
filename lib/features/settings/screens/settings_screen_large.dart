part of 'settings_screen.dart';

Widget buildLargeScreenBody({
  required BuildContext context,
  required TextEditingController loanInterestRateController,
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
            allowTextControllerUpdate = false;

            if (state.message != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message!)));
            }

            context.read<LoanBloc>().getSettings();
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
