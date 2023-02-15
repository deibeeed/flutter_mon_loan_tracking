import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/main/bloc/menu_selection_cubit.dart';
import 'package:flutter_mon_loan_tracking/models/menu_item.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class MainWebScreenMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menuSelection = BlocProvider.of<MenuSelectionCubit>(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topRight: Constants.defaultRadius,
          bottomRight: Constants.defaultRadius,
        ),
      ),
      child: BlocBuilder<MenuSelectionCubit, MenuSelectionState>(
        builder: (context, state) {
          var page = 0;
          var addButtonTitle = 'Add Loan';
          var addButtonPath = '/add-loan';

          if (state is MenuPageSelected) {
            page = state.page;
          }

          switch (page) {
            case 0:
              addButtonTitle = 'Add Loan';
              addButtonPath = '/add-loan';
              break;
            case 1:
              addButtonTitle = 'Add Lot';
              addButtonPath = '/add-lot';
              break;
            case 2:
              addButtonTitle = 'Add User';
              addButtonPath = '/add-user';
              break;
          }

          return ListView(
            children: [
              Container(
                margin: EdgeInsets.only(right: 24),
                padding: EdgeInsets.all(48),
                child: InkWell(
                  onTap: () => GoRouter.of(context).push(addButtonPath),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    color: Colors.white,
                    dashPattern: const [6, 4],
                    strokeWidth: 2,
                    padding: const EdgeInsets.all(24),
                    radius: Constants.defaultRadius,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16,),
                        Text(
                          addButtonTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.apply(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < Constants.menuItems.length; i++)
                _buildMenuItem(
                  context: context,
                  item: Constants.menuItems[i],
                  selected: page == i,
                  onTap: () {
                    menuSelection.select(page: i);
                    GoRouter.of(context).go(Constants.menuItems[i].goPath);
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required MenuItemModel item,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    if (item.isSeparator) {
      return const Padding(
        padding: EdgeInsets.only(left: 40, right: 64, top: 16, bottom: 16),
        child: Divider(
          color: Colors.white,
          thickness: 1.5,
          height: 4,
        ),
      );
    }
    return ListTile(
        minVerticalPadding: 32,
        leading: Container(
          width: 7,
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 100),
            child: Text(
              item.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.apply(color: Colors.white),
            ),
          ),
        ),
        onTap: onTap);
  }
}
