import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mon_loan_tracking/features/loan/bloc/loan_bloc.dart';
import 'package:flutter_mon_loan_tracking/features/users/bloc/user_bloc.dart';
import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_display.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/payment_frequency.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:flutter_mon_loan_tracking/widgets/pdf_generator.dart';
import 'package:flutter_mon_loan_tracking/widgets/widget_utils.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'add_loan_screen_large.dart';

part 'add_loan_screen_small.dart';

class AddLoanScreen extends StatefulWidget {
  AddLoanScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormBuilderState>(debugLabel: 'add_loan_screen');
  final pagingController = PagingController<int, LoanSchedule>(firstPageKey: 0);

  @override
  void deactivate() {
    context.read<LoanBloc>()
      ..reset()
      ..getAllLoans(clearList: true);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    context.read<UserBloc>().getAllUsers();
    final loanBloc = BlocProvider.of<LoanBloc>(context)..getSettings();
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;
    var buttonPadding = const EdgeInsets.all(24);
    var computationDetailsWidth = screenSize.width * 0.2;

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
      buttonPadding = const EdgeInsets.all(16);
      computationDetailsWidth = screenSize.width * 0.3;
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
    var isLargeScreenBreakpoint = false;

    if (appBarHeight > Constants.maxAppBarHeight) {
      appBarHeight = Constants.maxAppBarHeight;
    }

    if (shortestSide < Constants.largeScreenShortestSideBreakPoint) {
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
      isLargeScreenBreakpoint = true;
    }

    return BlocListener<LoanBloc, LoanState>(
      listener: (context, state) async {
        if (state is LoanSuccessState) {
          if (loanBloc.settings != null) {
            pagingController.value = PagingState(
              itemList: loanBloc.clientLoanSchedules,
            );
          }
        } else if (state is LoanErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is LoanLoadingState) {
          if (state.isLoading) {
            await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const AlertDialog(
                    content: SizedBox(
                      width: 80,
                      height: 80,
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
        } else if (state is CloseAddLoanState) {
          GoRouter.of(context).pop();
        } else if (state is UserHasOutstandingLoanState) {
          await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('WARNING: Client has existing loan'),
                  content: Text(
                      'Client has an existing loan with an outstanding balance of ${state.outstandingBalance.toCurrency()}.\nIf you will proceed, the outstanding balance will be deducted from the loan amount.\n\nDo you wish to proceed?'),
                  actions: [
                    FilledButton(
                        onPressed: () {
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            loanBloc.addLoan(
                              monthsToPay: int.parse(_formKey
                                  .currentState!.value['term'] as String),
                              date: _formKey.currentState!.value['date']
                                  as DateTime,
                              amount: double.parse(_formKey
                                  .currentState!.value['amount'] as String),
                              paymentFrequency: _formKey
                                      .currentState!.value['payment_frequency']
                                  as PaymentFrequency,
                              isReloan: true,
                            );
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        },
                        child: Text('Yes')),
                    FilledButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Text('No')),
                  ],
                );
              });
        } else if (state is PrintReloanStatementState) {
         await PdfGenerator.generatePdf(
            schedules: state.schedules,
            loan: state.loan,
            user: loanBloc.selectedUser,
          );

         GoRouter.of(context).pop();
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
                            'Add loan',
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
        body: shortestSide <= Constants.smallScreenShortestSideBreakPoint
            ? buildSmallScreenBody(
                context: context,
                pagingController: pagingController,
                formKey: _formKey,
              )
            : buildLargeScreenBody(
                context: context,
                pagingController: pagingController,
                formKey: _formKey,
              ),
      ),
    );
  }
}
