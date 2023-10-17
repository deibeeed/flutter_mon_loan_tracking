class SettingsNotFoundException implements Exception {
  SettingsNotFoundException({ this. message });
  final String? message;

  @override
  String toString() {
    return 'SettingsNotFoundException: $message';
  }
}