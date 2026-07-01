import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/widgets/error_view.dart';

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ErrorView', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(buildApp(
        const ErrorView(message: 'Something went wrong'),
      ));

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should display error icon', (tester) async {
      await tester.pumpWidget(buildApp(
        const ErrorView(message: 'Error'),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show retry button when callback provided',
        (tester) async {
      var retried = false;
      await tester.pumpWidget(buildApp(
        ErrorView(
          message: 'Failed',
          onRetry: () => retried = true,
        ),
      ));

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('should not show retry without callback', (tester) async {
      await tester.pumpWidget(buildApp(
        const ErrorView(message: 'Error'),
      ));

      expect(find.text('Retry'), findsNothing);
    });
  });
}
