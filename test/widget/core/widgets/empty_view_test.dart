import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/widgets/empty_view.dart';

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('EmptyView', () {
    testWidgets('should display message', (tester) async {
      await tester.pumpWidget(buildApp(
        const EmptyView(message: 'Nothing here'),
      ));

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('should display icon', (tester) async {
      await tester.pumpWidget(buildApp(
        const EmptyView(
          message: 'Empty',
          icon: Icons.folder_open,
        ),
      ));

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('should display action button when provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildApp(
        EmptyView(
          message: 'No items',
          actionLabel: 'Add Item',
          onAction: () => tapped = true,
        ),
      ));

      expect(find.text('Add Item'), findsOneWidget);
      await tester.tap(find.text('Add Item'));
      expect(tapped, isTrue);
    });

    testWidgets('should not show button without action', (tester) async {
      await tester.pumpWidget(buildApp(
        const EmptyView(message: 'No data'),
      ));

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
