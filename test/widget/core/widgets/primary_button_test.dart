import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/widgets/primary_button.dart';

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(home: Scaffold(body: Center(child: child)));
  }

  group('PrimaryButton', () {
    testWidgets('should display label text', (tester) async {
      await tester.pumpWidget(buildApp(
        PrimaryButton(label: 'Submit', onPressed: () {}),
      ));

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildApp(
        PrimaryButton(label: 'Tap Me', onPressed: () => tapped = true),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('should show loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(buildApp(
        PrimaryButton(label: 'Loading', onPressed: () {}, isLoading: true),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('should not trigger onPressed when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildApp(
        PrimaryButton(
          label: 'Disabled',
          onPressed: () => tapped = true,
          isEnabled: false,
        ),
      ));

      await tester.tap(find.text('Disabled'));
      expect(tapped, isFalse);
    });

    testWidgets('should include semantic label', (tester) async {
      await tester.pumpWidget(buildApp(
        PrimaryButton(
          label: 'Action',
          onPressed: () {},
          semanticLabel: 'Primary action button',
        ),
      ));

      final semantics = tester.getSemantics(find.byType(PrimaryButton));
      expect(semantics.label, contains('Primary action button'));
    });

    testWidgets('should display icon when provided', (tester) async {
      await tester.pumpWidget(buildApp(
        PrimaryButton(
          label: 'Save',
          onPressed: () {},
          icon: Icons.save,
        ),
      ));

      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
