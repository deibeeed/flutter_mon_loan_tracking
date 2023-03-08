import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/lot_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/settings/bloc/setting_field.dart';
import 'package:flutter_mon_loan_tracking/features/settings/bloc/settings_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/debounce.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key}) : super();

  final loanInterestRateController = TextEditingController();
  final incidentalFeesRateController = TextEditingController();
  final reservationFeeController = TextEditingController();
  final lotCategoryNameController = TextEditingController();
  final lotCategoryPricePerSqmController = TextEditingController();
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
      body: shortestSide <= Constants.smallScreenShortestSideBreakPoint
          ? _buildSmallScreenBody(context: context)
          : _buildLargeScreenBody(context: context),
    );
  }

  Widget _buildSmallScreenBody({required BuildContext context}) {
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
              reservationFeeController.text =
                  settingsBloc.settings.reservationFee.toString();
              allowTextControllerUpdate = false;

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
                Row(
                  children: [
                    TextFormField(
                      enabled:
                          settingsBloc.selectedLotCategoryKeyToUpdate == null,
                      controller: lotCategoryNameController,
                      decoration: const InputDecoration(
                        label: Text('Lot categories'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: lotCategoryPricePerSqmController,
                      decoration: const InputDecoration(
                        label: Text('Rate per square meter'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (settingsBloc.selectedLotCategoryKeyToUpdate ==
                            null) {
                          settingsBloc.addLotCategory(
                            name: lotCategoryNameController.text,
                            ratePerSqm: lotCategoryPricePerSqmController.text,
                          );
                        } else {
                          settingsBloc.updateLotCategory(
                            name: lotCategoryNameController.text,
                            ratePerSqm: lotCategoryPricePerSqmController.text,
                          );
                        }

                        lotCategoryNameController.text = '';
                        lotCategoryPricePerSqmController.text = '';
                      },
                      icon: settingsBloc.selectedLotCategoryKeyToUpdate == null
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
                    ),
                  ],
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
                        backgroundColor: Theme.of(context).colorScheme.primary),
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
    );
  }

  Widget _buildLargeScreenBody({required BuildContext context}) {
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
              reservationFeeController.text =
                  settingsBloc.settings.reservationFee.toString();
              allowTextControllerUpdate = false;

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
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller:
                                        lotCategoryPricePerSqmController,
                                    decoration: const InputDecoration(
                                      label: Text('Rate per square meter'),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      onPressed: () {
                                        if (settingsBloc
                                                .selectedLotCategoryKeyToUpdate ==
                                            null) {
                                          settingsBloc.addLotCategory(
                                            name:
                                                lotCategoryNameController.text,
                                            ratePerSqm:
                                                lotCategoryPricePerSqmController
                                                    .text,
                                          );
                                        } else {
                                          settingsBloc.updateLotCategory(
                                            name:
                                                lotCategoryNameController.text,
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
            )
          ],
        ),
      ),
    );
  }
}
