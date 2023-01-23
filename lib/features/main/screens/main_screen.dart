import 'package:flutter/material.dart';
import 'package:flutter_mon_loan_tracking/features/main/screens/main_web_screen.dart';

/// the container screen that contains all screens after login and splash
class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return MainWebScreen(content: content,);
  }

}