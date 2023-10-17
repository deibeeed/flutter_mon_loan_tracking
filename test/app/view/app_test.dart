import 'package:flutter_mon_loan_tracking/app/app.dart';
import 'package:flutter_mon_loan_tracking/features/loan/screens/loan_dashboard_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(App());
      expect(find.byType(LoanDashboardScreen), findsOneWidget);
    });
  });
}
