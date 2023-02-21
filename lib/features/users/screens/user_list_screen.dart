import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:go_router/go_router.dart';

class UserListScreen extends StatelessWidget {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    final screenSize = MediaQuery.of(context).size;
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(
        color: Colors.transparent,
        width: 0,
        style: BorderStyle.none,
      ),
    );
    final shortestSide = screenSize.shortestSide;
    var searchTextFieldPadding = const EdgeInsets.only(
      left: 32,
      right: 32,
      top: 20,
      bottom: 20,
    );
    var searchContainerPadding = const EdgeInsets.only(
      left: 24,
      top: 24,
      bottom: 24,
    );
    var searchButtonPadding = const EdgeInsets.all(22);
    var searchTextFieldWidth = screenSize.width * 0.3;

    if (shortestSide < Constants.largeScreenSmallestSideBreakPoint) {
      searchTextFieldPadding = const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 16,
        bottom: 16,
      );
      searchContainerPadding = const EdgeInsets.all(16);
      searchButtonPadding = const EdgeInsets.all(16);
      searchTextFieldWidth = screenSize.width * 0.5;
    }

    userBloc.getAllUsers();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Card(
              shadowColor: Colors.black,
              elevation: 16,
              child: Column(
                children: [
                  Padding(
                    padding:
                        searchContainerPadding,
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
                          width: searchTextFieldWidth,
                          child: TextFormField(
                            // style: TextStyle(fontSize: 16, ),
                            controller: _searchController,
                            decoration: InputDecoration(
                              contentPadding: searchTextFieldPadding,
                              label:
                                  const Text('Search users by name or email'),
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
                                // to load all users
                                userBloc.search(query: '');
                              }
                            },
                            onFieldSubmitted: (value) {
                              userBloc.search(query: value);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            userBloc.search(query: _searchController.text);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: searchButtonPadding,
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
                        BlocBuilder<UserBloc, UserState>(
                          buildWhen: (previous, current) =>
                          current is UserLoadingState ||
                              current is UserErrorState,
                          builder: (context, state) {
                            if (state is UserLoadingState) {
                              if (state.isLoading) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                            }

                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox.expand(
                      child: BlocBuilder<UserBloc, UserState>(
                        buildWhen: (previous, current) =>
                            current is UserSuccessState,
                        builder: (context, state) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                showCheckboxColumn: false,
                                dataRowHeight: 72,
                                headingRowColor: MaterialStateColor.resolveWith(
                                      (states) => Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withOpacity(0.32),
                                ),
                                columns: [
                                  for (String name
                                  in Constants.user_list_table_colums)
                                    DataColumn(
                                        label: Text(
                                          name.toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.apply(
                                            fontWeightDelta: 3,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ))
                                ],
                                rows: userBloc.filteredUsers
                                    .map(
                                      (user) => DataRow(
                                    onSelectChanged: (value) {
                                      Constants.menuItems.add(
                                        DynamicMenuItem(
                                          name: user.completeName,),
                                      );
                                      context.read<MenuSelectionCubit>().select(
                                        page:
                                        Constants.menuItems.length - 1,
                                      );
                                      userBloc.selectUser(userId: user.id);
                                      GoRouter.of(context)
                                          .go('/users/${user.id}');
                                    },
                                    cells: [
                                      DataCell(
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            defaultCellText(
                                              text: user.completeName,
                                            ),
                                            Text(
                                              user.email,
                                            )
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        defaultCellText(
                                          text: user.civilStatus.value,
                                        ),
                                      ),
                                      DataCell(
                                        defaultCellText(text: user.type.value),
                                      ),
                                      DataCell(
                                        defaultCellText(
                                            text: user.mobileNumber),
                                      ),
                                      DataCell(
                                        defaultCellText(
                                          text: user.birthDate,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text defaultCellText({required String text}) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
