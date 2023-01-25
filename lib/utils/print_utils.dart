import 'package:flutter/foundation.dart';

/// printing on debug
void printd(Object? content) {
  if (kDebugMode) {
    print(content);
  }
}