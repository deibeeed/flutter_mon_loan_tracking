import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/settings/bloc/setting_field.dart';
import 'package:flutter_mon_loan_tracking/features/settings/bloc/settings_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/debounce.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key}) : super();

  final loanInterestRateController = TextEditingController();
  final incidentalFeesRateController = TextEditingController();
  final reservationFeeController = TextEditingController();
  final lotCategoryController = TextEditingController();
  final perSqmController = TextEditingController();
  bool allowTextControllerUpdate = true;

  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    settingsBloc.getSettings();

    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsSuccessState) {
              if (allowTextControllerUpdate) {
                loanInterestRateController.text =
                    settingsBloc.settings.loanInterestRate.toString();
                incidentalFeesRateController.text =
                    settingsBloc.settings.incidentalFeeRate.toString();
                reservationFeeController.text =
                    settingsBloc.settings.reservationFee.toString();
                perSqmController.text =
                    settingsBloc.settings.perSquareMeterRate.toString();
                allowTextControllerUpdate = false;
              }
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const Text('Per square meter rate'),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previousState, currentState) {
                      return currentState is SettingsSuccessState;
                    },
                    builder: (context, state) {
                      return Text(
                        settingsBloc.settings.perSquareMeterRate
                            .toCurrency(),
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
                  const Text('Reservation fee'),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previousState, currentState) {
                      return currentState is SettingsSuccessState;
                    },
                    builder: (context, state) {
                      return Text(
                        settingsBloc.settings.reservationFee.toCurrency(),
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
                            Text(category),
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
                controller: perSqmController,
                decoration: const InputDecoration(
                  label: Text('Per square meter rate'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                ],
                onChanged: (value) => settingsBloc.updateSettings(
                  field: SettingField.perSquareMeterRate,
                  value: value,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              TextFormField(
                controller: reservationFeeController,
                decoration: const InputDecoration(
                  label: Text('Reservation fee'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                ],
                onChanged: (value) => settingsBloc.updateSettings(
                  field: SettingField.reservationFee,
                  value: value,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: lotCategoryController,
                    decoration: InputDecoration(
                      label: Text('Lot categories'),
                      border: OutlineInputBorder(),
                      suffix: IconButton(
                        onPressed: () => settingsBloc.updateSettings(
                          field: SettingField.lotCategory,
                          value: lotCategoryController.text,
                        ),
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ),
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
                            Chip(
                              padding: const EdgeInsets.only(
                                  left: 8, top: 8, bottom: 8, right: 16),
                              label: Text(category),
                              onDeleted: () => settingsBloc
                                  .removeLotCategory(category: category),
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
        ),
      ),
    );
  }
}
