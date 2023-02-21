import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/lot_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';

class LotDetailsScreen extends StatefulWidget {
  String? lotId;

  @override
  State<StatefulWidget> createState() => _LotDetailsScreenState();

}

class _LotDetailsScreenState extends State<LotDetailsScreen> {
  final _blockNoController = TextEditingController();
  final _lotNoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController();

  @override
  void deactivate() {
    final menuItemLast = Constants.menuItems.last;

    if (menuItemLast.isDynamic) {
      Constants.menuItems.removeLast();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final lotBloc = BlocProvider.of<LotBloc>(context);

    if (lotBloc.selectedLot != null){
      final lot = lotBloc.selectedLot!;
      _blockNoController.text = lot.blockNo;
      _lotNoController.text = lot.lotNo;
      _areaController.text = lot.area.toString();
      _descriptionController.text = lot.description;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: BlocListener<LotBloc, LotState>(
          listener: (context, state) {
            if (state is LotSuccessState) {
              if (lotBloc.selectedLot != null){
                final lot = lotBloc.selectedLot!;
                _blockNoController.text = lot.blockNo;
                _lotNoController.text = lot.lotNo;
                _areaController.text = lot.area.toString();
                _descriptionController.text = lot.description;
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
                        const Text('Block No.'),
                        BlocBuilder<LoanBloc, LoanState>(
                          buildWhen: (previousState, currentState) {
                            return currentState is LotSuccessState;
                          },
                          builder: (context, state) {
                            return Text(
                              '${lotBloc.selectedLot?.blockNo}',
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
                        const Text('Block No.'),
                        BlocBuilder<LoanBloc, LoanState>(
                          buildWhen: (previousState, currentState) {
                            return currentState is LotSuccessState;
                          },
                          builder: (context, state) {
                            return Text(
                              '${lotBloc.selectedLot?.lotNo}',
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
                        const Text('Area'),
                        BlocBuilder<LoanBloc, LoanState>(
                          buildWhen: (previousState, currentState) {
                            return currentState is LotSuccessState;
                          },
                          builder: (context, state) {
                            return Text(
                              '${lotBloc.selectedLot?.area}',
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
                        const Text('Lot category'),
                        BlocBuilder<LoanBloc, LoanState>(
                          buildWhen: (previousState, currentState) {
                            return currentState is LotSuccessState;
                          },
                          builder: (context, state) {
                            return Text(
                              '${lotBloc.selectedLot?.lotCategory}',
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
                        const Text('Description'),
                        BlocBuilder<LoanBloc, LoanState>(
                          buildWhen: (previousState, currentState) {
                            return currentState is LotSuccessState;
                          },
                          builder: (context, state) {
                            return Text(
                              '${lotBloc.selectedLot?.description}',
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
                        const Text('Reserved to'),
                        BlocBuilder<LoanBloc, LoanState>(
                          buildWhen: (previousState, currentState) {
                            return currentState is LotSuccessState;
                          },
                          builder: (context, state) {
                            return Text(
                              lotBloc.selectedLot?.reservedTo ?? 'Available',
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
                child: BlocBuilder<LotBloc, LotState>(
                  buildWhen: (previous, current) => current is LotSuccessState,
                  builder: (context, state) {
                    return Column(
                      children: [
                        TextFormField(
                          controller: _blockNoController,
                          decoration: const InputDecoration(
                            label: Text('Block no'),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                          ],
                          onChanged: (value) {
                            // settingsBloc.updateSettings(
                            //   field: SettingField.loanInterestRate,
                            //   value: value,
                            // );
                          },
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        TextFormField(
                          controller: _lotNoController,
                          decoration: const InputDecoration(
                            label: Text('Lot no'),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                          ],
                          // onChanged: (value) => settingsBloc.updateSettings(
                          //   field: SettingField.incidentalFeeRate,
                          //   value: value,
                          // ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        TextFormField(
                          controller: _areaController,
                          decoration: const InputDecoration(
                            label: Text('Area'),
                            suffixText: 'sqm',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                          ],
                          // onChanged: (value) => settingsBloc.updateSettings(
                          //   field: SettingField.perSquareMeterRate,
                          //   value: value,
                          // ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: BlocBuilder<LotBloc, LotState>(
                            builder: (context, state) {
                              var dropdownValue = lotBloc.lotCategories.first;

                              if (lotBloc.selectedLot != null) {
                                dropdownValue = lotBloc.selectedLot!.lotCategory;
                              }

                              if (state is SelectedLotCategoryLotState) {
                                dropdownValue = state.selectedLotCategory;
                              }

                              return DropdownButton<String>(
                                value: dropdownValue,
                                items: lotBloc.lotCategories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (value) => lotBloc.selectLotCategory(
                                  lotCategory: value,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            label: Text('Lot description'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 56,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => lotBloc.updateLot(
                                  area: _areaController.text,
                                  blockNo: _blockNoController.text,
                                  lotNo: _lotNoController.text,
                                  description: _descriptionController.text,
                                ),
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(24),
                                    backgroundColor:
                                    Theme.of(context).colorScheme.primary),
                                child: Text(
                                  'Update lot',
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
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
