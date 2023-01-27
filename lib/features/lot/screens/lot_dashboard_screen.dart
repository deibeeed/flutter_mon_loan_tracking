import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/general_lot_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class LotDashboardScreen extends StatelessWidget {
  const LotDashboardScreen({super.key}) : super();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(
        color: Colors.transparent,
        width: 0,
        style: BorderStyle.none,
      ),
    );
    final generalFilterCubit = BlocProvider.of<GeneralLotFilterSelectionCubit>(
      context,
    );
    const defaultTableTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      body: Column(
        children: [
          BlocBuilder<GeneralLotFilterSelectionCubit,
              GeneralLotFilterSelectionState>(
            builder: (context, state) {
              var position = 0;

              if (state is FilterSelectedState) {
                position = state.position;
              }

              return Row(
                children: [
                  for (var i = 0;
                      i < Constants.lot_dashbaord_general_filters.length;
                      i++)
                    Column(
                      children: [
                        TextButton(
                          onPressed: () =>
                              generalFilterCubit.select(position: i),
                          child: Text(
                            Constants.lot_dashbaord_general_filters[i],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.apply(
                                    fontSizeDelta: 2,
                                    fontWeightDelta: 2,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          ),
                        ),
                        Visibility(
                          visible: position == i,
                          child: Container(
                            height: 2,
                            width: 56,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        )
                      ],
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              height: 2,
              width: double.infinity,
            ),
          ),
          Expanded(
            child: Card(
              color: Colors.white,
              shadowColor: Colors.black,
              elevation: 16,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, top: 24, bottom: 24),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => printd('hello'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(22),
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.8),
                            side: BorderSide(
                              width: 1.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.filter_alt_rounded),
                              Text(
                                'FILTER',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 32,
                        ),
                        SizedBox(
                          width: screenSize.width * 0.3,
                          child: TextFormField(
                            // style: TextStyle(fontSize: 16, ),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 32, right: 32, top: 20, bottom: 20),
                                label:
                                    const Text('Search by block or lot number'),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                border: defaultBorder,
                                enabledBorder: defaultBorder,
                                focusedBorder: defaultBorder),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                  ),
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => printd('tapped'),
                            child: Chip(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.8),
                              surfaceTintColor: Colors.red,
                              padding: EdgeInsets.all(12),
                              label: Text('Block 1', style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => printd('tapped'),
                            child: Chip(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.4),
                              surfaceTintColor: Colors.red,
                              padding: EdgeInsets.all(12),
                              label: Text('Block 2', style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: SizedBox(
                        width: screenSize.width * 0.65,
                        // height: screenSize.height * 0.4,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiary
                                    .withOpacity(0.8),
                                borderRadius: BorderRadius.circular(120),
                              ),
                              padding: EdgeInsets.all(32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Text(
                                      'Block 1',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.apply(
                                            fontWeightDelta: 2,
                                            color: Colors.white,
                                            letterSpacingDelta: 2,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    margin: EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(80),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.apply(fontWeightDelta: 2),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.apply(fontWeightDelta: 2),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    margin: EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(80),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    margin: EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(80),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(64),
                                          ),
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                              'hello',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text('Lot pages here'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
