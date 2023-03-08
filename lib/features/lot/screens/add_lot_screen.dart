import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/lot_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/lot_category.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class AddLotScreen extends StatefulWidget {
  AddLotScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddLotScreenState();

}
class _AddLotScreenState extends State<AddLotScreen> {

  @override
  void initState() {
    super.initState();

    final lotBloc = BlocProvider.of<LotBloc>(context);
    lotBloc.initialize();
  }

  final blockLotNumberController = TextEditingController();
  final lotDescriptionController = TextEditingController();
  final areaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lotBloc = BlocProvider.of<LotBloc>(context);

    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);
    final width = screenSize.width;
    final computedWidth = width * 0.88;
    var appBarHeight = screenSize.height * 0.16;
    var appBarBottomPadding = 48.0;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;
    var titleTextStyle = Theme.of(context).textTheme.displaySmall;
    var avatarTextStyle = Theme.of(context).textTheme.titleLarge;
    var avatarSize = 56.0;

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      appBarBottomPadding = 24;
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
      titleTextStyle = Theme.of(context).textTheme.headlineMedium;
      avatarTextStyle = Theme.of(context).textTheme.titleSmall;
      avatarSize = 48;
    }

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

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
        appBar: !widget.isMobile()
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(appBarHeight),
                child: AppBar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.48),
                  leading: !widget.isMobile() ? Container() : IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => GoRouter.of(context).pop(),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.zero,
                    child: Container(
                      width: computedWidth,
                      margin: EdgeInsets.only(bottom: appBarBottomPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add lot',
                            style: titleTextStyle?.apply(color: Colors.white),
                          ),
                          SizedBox(
                            width: avatarSize,
                            height: avatarSize,
                            child: InkWell(
                              onTap: () {
                                final user =
                                    context.read<UserBloc>().getLoggedInUser();
                                if (user != null) {
                                  GoRouter.of(context)
                                      .push('/users/${user.id}');
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    context
                                            .read<UserBloc>()
                                            .getLoggedInUser()
                                            ?.initials ??
                                        'No',
                                    style: avatarTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: loginContainerRadius,
                      bottomRight: loginContainerRadius,
                    ),
                  ),
                ),
              ),
        body: SingleChildScrollView(
          child: Padding(
            padding: shortestSide <= Constants.smallScreenShortestSideBreakPoint
                ? const EdgeInsets.all(16)
                : EdgeInsets.zero,
            child: Column(
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
                      var dropdownValue = lotBloc.lotCategories.first;

                      if (state is SelectedLotCategoryLotState) {
                        dropdownValue = state.selectedLotCategory;
                      }

                      return DropdownButton<LotCategory>(
                        value: dropdownValue,
                        items: lotBloc.lotCategories.map((category) {
                          return DropdownMenuItem<LotCategory>(
                            value: category,
                            child: Text(category.name),
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
                      helperText: 'Format: block:lot[,block:lot,etc]',
                      border: OutlineInputBorder(),),
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFormField(
                  controller: lotDescriptionController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                      label: Text('Lot description'),
                      border: OutlineInputBorder()),
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
                          padding: buttonPadding,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
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
        ),
      ),
    );
  }
}
