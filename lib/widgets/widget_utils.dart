import 'package:flutter/material.dart';

Text defaultCellText({ required String text }) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );
}