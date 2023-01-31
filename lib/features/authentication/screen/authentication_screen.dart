import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:go_router/go_router.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final computedWidth = width * 0.88;
    var loginContainerWidth = width * 0.315;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(220),
        child: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.48),
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Container(
              width: computedWidth,
              margin: const EdgeInsets.only(bottom: 48),
              // child: BlocBuilder<MenuSelectionCubit, MenuSelectionState>(
              //   builder: (context, state) {
              //     var menuItemName = Constants.menuItems[0].name;
              //     if (state is MenuPageSelected) {
              //       menuItemName = Constants.menuItems[state.page].name;
              //     }
              //
              //     return Text(
              //       menuItemName,
              //       style: Theme.of(context)
              //           .textTheme
              //           .displaySmall
              //           ?.apply(color: Colors.white),
              //     );
              //   },
              // ),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Constants.defaultRadius,
              bottomRight: Constants.defaultRadius,
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 64),
        height: double.infinity,
        width: loginContainerWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topRight: Constants.defaultRadius,
            bottomRight: Constants.defaultRadius,
          ),
        ),
        child: Center(
          child: SizedBox(
            height: 600,
            width: 600,
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                child: Padding(
                  padding: EdgeInsets.all(56),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text('Email'),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 32,),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          label: Text('Pasword'),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 72,),
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => print('pressed'),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(24),
                              backgroundColor: Theme.of(context).colorScheme.primary),
                          child: Text(
                            'Login',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.apply(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
