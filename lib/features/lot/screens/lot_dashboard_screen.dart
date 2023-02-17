import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/general_lot_filter_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/lot_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class LotDashboardScreen extends StatelessWidget {
  LotDashboardScreen({super.key}) : super();

  String _selectedBlock = '';
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lotBloc = BlocProvider.of<LotBloc>(context);
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
                          onPressed: () {
                            lotBloc.filter(
                                filter:
                                    Constants.lot_dashbaord_general_filters[i]);
                            generalFilterCubit.select(position: i);
                          },
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
              shadowColor: Colors.black,
              elevation: 16,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, top: 24, bottom: 24),
                    child: Row(
                      children: [
                        // OutlinedButton(
                        //   onPressed: () => printd('hello'),
                        //   style: OutlinedButton.styleFrom(
                        //     padding: const EdgeInsets.all(22),
                        //     foregroundColor: Theme.of(context)
                        //         .colorScheme
                        //         .secondary
                        //         .withOpacity(0.8),
                        //     side: BorderSide(
                        //       width: 1.5,
                        //       color: Theme.of(context)
                        //           .colorScheme
                        //           .secondary
                        //           .withOpacity(0.8),
                        //     ),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       const Icon(Icons.filter_alt_rounded),
                        //       Text(
                        //         'FILTER',
                        //         style: Theme.of(context).textTheme.titleMedium,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(
                        //   width: 32,
                        // ),
                        SizedBox(
                          width: screenSize.width * 0.3,
                          child: TextFormField(
                            // style: TextStyle(fontSize: 16, ),
                            controller: _searchController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                left: 32,
                                right: 32,
                                top: 20,
                                bottom: 20,
                              ),
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
                              focusedBorder: defaultBorder,
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                // to load all lots
                                _selectedBlock = '';
                                lotBloc.search(query: '');
                              }
                            },
                            onFieldSubmitted: (value) {
                              lotBloc.search(query: value);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _selectedBlock = '';
                            lotBloc.search(query: _searchController.text);
                          },
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
                              const Icon(Icons.search_rounded),
                              Text(
                                'Search',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
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
                    padding: const EdgeInsets.all(32),
                    child: BlocBuilder<LotBloc, LotState>(
                      buildWhen: (previous, current) =>
                          current is LotSuccessState,
                      builder: (context, state) {
                        if (_selectedBlock.isEmpty) {
                          _selectedBlock =
                              lotBloc.filteredGroupedLots.keys.first;
                        }

                        return Row(
                          children:
                              lotBloc.filteredGroupedLots.keys.map((blockNo) {
                            var opacity = 0.4;
                            if (blockNo == _selectedBlock) {
                              opacity = 0.8;
                            }

                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  _selectedBlock = blockNo;
                                  lotBloc.selectBlock(blockNo: blockNo);
                                },
                                child: Chip(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .tertiary
                                      .withOpacity(opacity),
                                  surfaceTintColor: Colors.red,
                                  padding: const EdgeInsets.all(12),
                                  label: Text(
                                    'Block $blockNo',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: SizedBox(
                        width: screenSize.width * 0.65,
                        // height: screenSize.height * 0.4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.8),
                            borderRadius: BorderRadius.circular(120),
                          ),
                          padding: const EdgeInsets.all(32),
                          child: BlocBuilder<LotBloc, LotState>(
                            buildWhen: (previous, current) =>
                                current is LotSuccessState,
                            builder: (context, state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Text(
                                      'Block $_selectedBlock',
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
                                  ...lotBloc
                                      .chunkedLots(
                                          lots: lotBloc.filteredGroupedLots[
                                              _selectedBlock]!)
                                      .map(
                                        (lots) => Container(
                                          padding: const EdgeInsets.all(32),
                                          margin: const EdgeInsets.all(32),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(80),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: lots
                                                .map((lot) => Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getLotBackgroundColor(
                                                          context: context,
                                                          isReserved:
                                                              lot.reservedTo !=
                                                                  null,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(64),
                                                      ),
                                                      width: 200,
                                                      height: 200,
                                                      child: Center(
                                                        child: Text(
                                                          'Lot ${lot.lotNo}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleLarge,
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Text('Lot pages here'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLotBackgroundColor({
    required BuildContext context,
    required bool isReserved,
  }) {
    if (isReserved) {
      return Theme.of(context).colorScheme.errorContainer;
    }

    return Theme.of(context).colorScheme.secondaryContainer;
  }
}
