import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('auth screen here'),
          ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/lot-dashboard'),
              child: Text('go to dashboard'))
        ],
      ),
    );
  }
}
