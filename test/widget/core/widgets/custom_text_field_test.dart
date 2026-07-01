import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/widgets/custom_text_field.dart';

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  group('CustomTextField', () {
    testWidgets('should display label', (tester) async {
      await tester.pumpWidget(buildApp(
        const CustomTextField(label: 'Email'),
      ));

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should accept text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildApp(
        CustomTextField(label: 'Name', controller: controller),
      ));

      await tester.enterText(find.byType(TextFormField), 'John');
      expect(controller.text, 'John');
    });

    testWidgets('should show error text', (tester) async {
      await tester.pumpWidget(buildApp(
        const CustomTextField(
          label: 'Password',
          errorText: 'Too short',
        ),
      ));

      expect(find.text('Too short'), findsOneWidget);
    });

    testWidgets('should call onChanged', (tester) async {
      String? changedValue;
      await tester.pumpWidget(buildApp(
        CustomTextField(
          label: 'Search',
          onChanged: (v) => changedValue = v,
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'test');
      expect(changedValue, 'test');
    });

    testWidgets('should display prefix icon', (tester) async {
      await tester.pumpWidget(buildApp(
        const CustomTextField(
          label: 'Email',
          prefixIcon: Icons.email,
        ),
      ));

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('should obscure text when obscureText is true',
        (tester) async {
      await tester.pumpWidget(buildApp(
        const CustomTextField(
          label: 'Password',
          obscureText: true,
        ),
      ));

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.obscureText, isTrue);
    });
  });
}
