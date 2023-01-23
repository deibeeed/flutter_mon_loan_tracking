import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWebScreen extends StatelessWidget {
  const MainWebScreen({super.key, required this.content});

  final Widget content;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: ListView(
              children: [
                ListTile(
                  title: Text('dashboard'),
                  onTap: () => GoRouter.of(context).go('/dashboard'),
                ),
                ListTile(
                  title: Text('users'),
                    onTap: () => GoRouter.of(context).go('/users')
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: content,
          )
        ],
      ),
    );
  }
}
