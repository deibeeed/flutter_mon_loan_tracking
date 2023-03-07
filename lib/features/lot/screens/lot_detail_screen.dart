import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/lot/bloc/lot_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/user_type.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:go_router/go_router.dart';

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
    final lotBloc = BlocProvider.of<LotBloc>(context);
    final loanBloc = BlocProvider.of<LoanBloc>(context);

    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    if (lotBloc.selectedLot != null) {
      final lot = lotBloc.selectedLot!;
      _blockNoController.text = lot.blockNo;
      _lotNoController.text = lot.lotNo;
      _areaController.text = lot.area.toString();
      _descriptionController.text = lot.description;
    }

    final width = screenSize.width;
    final computedWidth = width * 0.88;
    var appBarHeight = screenSize.height * 0.16;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;
    var titleTextStyle = Theme.of(context).textTheme.displaySmall;
    var avatarTextStyle = Theme.of(context).textTheme.titleLarge;
    var avatarSize = 56.0;
    var contentPadding = const EdgeInsets.all(58);
    var appBarBottomPadding = 48.0;

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
      titleTextStyle = Theme.of(context).textTheme.headlineMedium;
      avatarTextStyle = Theme.of(context).textTheme.titleSmall;
      avatarSize = 48;
      contentPadding = const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 16,
        bottom: 16,
      );
      appBarBottomPadding = 24;
    }

    return Scaffold(
      appBar: !widget.isMobile()
          ? null
          : PreferredSize(
              preferredSize: Size.fromHeight(appBarHeight),
              child: AppBar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.48),
                leading: !widget.isMobile()
                    ? Container()
                    : IconButton(
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
                          lotBloc.selectedLot?.completeBlockLotNo ??
                              'Block & Lot',
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
                                GoRouter.of(context).push('/users/${user.id}');
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
      body: shortestSide <= Constants.smallScreenShortestSideBreakPoint
          ? _buildSmallScreenBody(context: context)
          : _buildLargeScreenBody(context: context),
    );
  }

  Widget _buildSmallScreenBody({required BuildContext context}) {
    final lotBloc = BlocProvider.of<LotBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);

    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    if (lotBloc.selectedLot != null) {
      final lot = lotBloc.selectedLot!;
      _blockNoController.text = lot.blockNo;
      _lotNoController.text = lot.lotNo;
      _areaController.text = lot.area.toString();
      _descriptionController.text = lot.description;
    }

    final width = screenSize.width;
    final computedWidth = width * 0.88;
    var appBarHeight = screenSize.height * 0.16;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;
    var titleTextStyle = Theme.of(context).textTheme.displaySmall;
    var avatarTextStyle = Theme.of(context).textTheme.titleLarge;
    var avatarSize = 56.0;
    var contentPadding = const EdgeInsets.all(58);
    var appBarBottomPadding = 48.0;

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
      titleTextStyle = Theme.of(context).textTheme.headlineMedium;
      avatarTextStyle = Theme.of(context).textTheme.titleSmall;
      avatarSize = 48;
      contentPadding = const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 16,
        bottom: 16,
      );
      appBarBottomPadding = 24;
    }

    return SingleChildScrollView(
      child: BlocListener<LotBloc, LotState>(
        listener: (context, state) {
          if (state is LotSuccessState) {
            if (lotBloc.selectedLot != null) {
              final lot = lotBloc.selectedLot!;
              _blockNoController.text = lot.blockNo;
              _lotNoController.text = lot.lotNo;
              _areaController.text = lot.area.toString();
              _descriptionController.text = lot.description;
            }
          } else if (state is LotErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                height: 32,
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
                        userBloc.mappedUsers[lotBloc.selectedLot?.reservedTo]
                                ?.completeName ??
                            'Available',
                      );
                    },
                  ),
                ],
              ),
              // const SizedBox(
              //   height: 32,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     const Text('Assisting agent'),
              //     BlocBuilder<LoanBloc, LoanState>(
              //       buildWhen: (previousState, currentState) {
              //         return currentState is LotSuccessState;
              //       },
              //       builder: (context, state) {
              //         return Text(
              //           userBloc.mappedUsers[lotBloc.selectedLot?.assistingAgent]
              //                   ?.completeName ??
              //               'Available',
              //         );
              //       },
              //     ),
              //   ],
              // ),
              const SizedBox(
                height: 32,
              ),
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
                      dropdownValue = lotBloc.selectedLot!.lotCategory.name;
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
              Visibility(
                visible: [UserType.admin, UserType.subAdmin]
                    .contains(userBloc.getLoggedInUser()?.type),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => lotBloc.updateLot(
                      area: _areaController.text,
                      blockNo: _blockNoController.text,
                      lotNo: _lotNoController.text,
                      description: _descriptionController.text,
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: buttonPadding,
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      'Update lot',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.apply(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Visibility(
                visible: userBloc.getLoggedInUser()?.type == UserType.admin,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => lotBloc.deleteLot(),
                    style: ElevatedButton.styleFrom(
                        padding: buttonPadding,
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer),
                    child: Text(
                      'Delete lot',
                      style: Theme.of(context).textTheme.titleMedium?.apply(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreenBody({required BuildContext context}) {
    final lotBloc = BlocProvider.of<LotBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);

    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);

    if (lotBloc.selectedLot != null) {
      final lot = lotBloc.selectedLot!;
      _blockNoController.text = lot.blockNo;
      _lotNoController.text = lot.lotNo;
      _areaController.text = lot.area.toString();
      _descriptionController.text = lot.description;
    }

    final width = screenSize.width;
    final computedWidth = width * 0.88;
    var appBarHeight = screenSize.height * 0.16;
    var loginContainerRadius = Constants.defaultRadius;
    var loginContainerMarginTop = 64.0;
    var titleTextStyle = Theme.of(context).textTheme.displaySmall;
    var avatarTextStyle = Theme.of(context).textTheme.titleLarge;
    var avatarSize = 56.0;
    var contentPadding = const EdgeInsets.all(58);
    var appBarBottomPadding = 48.0;

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      loginContainerRadius = const Radius.circular(64);
      loginContainerMarginTop = 32;
      titleTextStyle = Theme.of(context).textTheme.headlineMedium;
      avatarTextStyle = Theme.of(context).textTheme.titleSmall;
      avatarSize = 48;
      contentPadding = const EdgeInsets.only(
        left: 32,
        right: 32,
        top: 16,
        bottom: 16,
      );
      appBarBottomPadding = 24;
    }

    return SingleChildScrollView(
      child: BlocListener<LotBloc, LotState>(
        listener: (context, state) {
          if (state is LotSuccessState) {
            if (lotBloc.selectedLot != null) {
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
                            userBloc
                                    .mappedUsers[
                                        lotBloc.selectedLot?.reservedTo]
                                    ?.completeName ??
                                'Available',
                          );
                        },
                      ),
                    ],
                  ),
                  // const SizedBox(
                  //   height: 16,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     const Text('Assisting agent'),
                  //     BlocBuilder<LoanBloc, LoanState>(
                  //       buildWhen: (previousState, currentState) {
                  //         return currentState is LotSuccessState;
                  //       },
                  //       builder: (context, state) {
                  //         return Text(
                  //           userBloc
                  //                   .mappedUsers[
                  //                       lotBloc.selectedLot?.assistingAgent]
                  //                   ?.completeName ??
                  //               'Available',
                  //         );
                  //       },
                  //     ),
                  //   ],
                  // ),
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
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                              dropdownValue = lotBloc.selectedLot!.lotCategory.name;
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
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => lotBloc.updateLot(
                                      area: _areaController.text,
                                      blockNo: _blockNoController.text,
                                      lotNo: _lotNoController.text,
                                      description: _descriptionController.text,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        padding: buttonPadding,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    child: Text(
                                      'Update lot',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.apply(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 32,
                                ),
                                Visibility(
                                  visible: userBloc.getLoggedInUser()?.type ==
                                      UserType.admin,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => lotBloc.deleteLot(),
                                      style: ElevatedButton.styleFrom(
                                          padding: buttonPadding,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .errorContainer),
                                      child: Text(
                                        'Delete lot',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
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
    );
  }
}
