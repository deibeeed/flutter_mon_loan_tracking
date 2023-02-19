import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/lot_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class AddLotScreen extends StatelessWidget {
  AddLotScreen({super.key});

  final blockLotNumberController = TextEditingController();
  final lotDescriptionController = TextEditingController();
  final areaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lotBloc = BlocProvider.of<LotBloc>(context);
    lotBloc.initialize();

    return BlocListener<LotBloc, LotState>(
      listener: (context, state) {
        if (state is LotLoadingState) {
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
        } else if (state is AddLotSuccessState) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
              ),
            );
          }
        } else if (state is CloseAddLotState) {
          GoRouter.of(context).pop();
        } else if (state is LotErrorState) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: SizedBox(
                    width: 56,
                    height: 56,
                    child: Text(state.message),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      child: const Text('CLOSE'),
                    )
                  ],
                );
              });
        }
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lot category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<LotBloc, LotState>(
                builder: (context, state) {
                  String dropdownValue = lotBloc.lotCategories.first;

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
              controller: areaController,
              decoration: const InputDecoration(
                label: Text('Area'),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            TextFormField(
              controller: blockLotNumberController,
              decoration: const InputDecoration(
                  label: Text('Block and lot numbers'),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 32,
            ),
            TextFormField(
              controller: lotDescriptionController,
              maxLines: 8,
              decoration: const InputDecoration(
                  label: Text('Lot description'), border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 96,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => lotBloc.addLot(
                        area: areaController.text,
                        blockLotNos: blockLotNumberController.text,
                        description: lotDescriptionController.text),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(24),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      'Add lot',
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
}
