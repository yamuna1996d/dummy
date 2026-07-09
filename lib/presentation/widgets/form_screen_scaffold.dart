import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';

/// Each top-level form item gets a block of 10 traversal-order slots
/// (see [FormFieldOrder]) so a composite child with several of its own
/// focusable fields (e.g. [MedicationFormFields]) can space its internal
/// fields out within its block without colliding with the next item's.
const int formFieldOrderStep = 10;

/// Standard scaffold for single-form screens (add/edit child, medication,
/// profile): an `AppBar` with [title], a scrollable, width-constrained,
/// centered `Form` wrapping [children] in a stretched column.
///
/// Keyboard/switch-control focus moves through [children] in the exact
/// order given, via explicit [FocusTraversalOrder] indices — not just
/// whatever order the widget tree happens to produce — so the order
/// can't silently drift if the layout is refactored later.
class FormScreenScaffold extends StatelessWidget {
  const FormScreenScaffold({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    this.floatingActionButton,
  });

  final Widget title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.horizontalPadding(context);
    final isWide = ResponsiveHelper.isTabletOrLarger(context);

    return Scaffold(
      appBar: AppBar(title: Semantics(headingLevel: 1, child: title)),
      floatingActionButton: floatingActionButton,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: AppDimensions.paddingLg,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 600 : double.infinity,
            ),
            child: Form(
              key: formKey,
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < children.length; i++)
                      FocusTraversalOrder(
                        order: NumericFocusOrder(
                          (i * formFieldOrderStep).toDouble(),
                        ),
                        child: children[i],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
