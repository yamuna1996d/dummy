import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_strings.dart';

/// Reusable dropdown-style field matching [CustomTextField]'s visual style.
///
/// Built on [FormField] + a custom bottom-sheet picker rather than
/// [DropdownButtonFormField]. Flutter's built-in dropdown bundles its
/// "open the menu" interaction together with its own internally-generated
/// accessibility label, with no public way to override one without losing
/// the other — so there's no way to make it announce exactly what we want
/// while keeping it reliably operable by a screen reader.
///
/// This version controls both sides explicitly: the same [_openPicker]
/// function is wired to both a real tap (via [InkWell]) and an
/// accessibility double-tap (via [Semantics.onTap]), so they can never
/// drift out of sync, and the announced text is built by hand so it always
/// reflects the field label, the *current* selected value, and a plain
/// instruction for what to do next.
class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.hint,
    this.validator,
    this.semanticLabel,
  });

  final String label;
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final FormFieldValidator<T>? validator;
  final String? semanticLabel;

  String _textFor(T? value) {
    if (value == null) return hint ?? AppStrings.notSelected;
    for (final item in items) {
      if (item.value == value) {
        final child = item.child;
        if (child is Text && child.data != null) return child.data!;
        return value.toString();
      }
    }
    return hint ?? AppStrings.notSelected;
  }

  Future<void> _openPicker(
      BuildContext context,
      FormFieldState<T> state,
      ) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Semantics(
                  headingLevel: 2,
                  child: Text(
                    AppStrings.selectLabel(semanticLabel ?? label),
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              for (final item in items)
                Builder(
                  builder: (context) {
                    final itemText = item.child is Text
                        ? ((item.child as Text).data ?? item.value.toString())
                        : item.value.toString();
                    final isSelected = item.value == state.value;

                    return Semantics(
                      button: true,
                      label: itemText,
                      hint: isSelected ? AppStrings.currentlySelected : null,
                      excludeSemantics: true,
                      onTap: () => Navigator.of(sheetContext).pop(item.value),
                      child: ListTile(
                        title: Text(itemText),
                        trailing: isSelected
                            ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                            : null,
                        onTap: () => Navigator.of(sheetContext).pop(item.value),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      state.didChange(selected);
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: initialValue,
      validator: validator,
      builder: (state) {
        final displayText = _textFor(state.value);
        final fieldLabel = semanticLabel ?? label;

        // Everything a screen-reader user needs in one announcement:
        // what the field is, what it's currently set to, and what
        // double-tapping it will do. The hint deliberately omits "double
        // tap" wording — with `button: true` set below, TalkBack/VoiceOver
        // already announce that automatically, so repeating it here would
        // just echo back-to-back.
        final semanticsLabel =
        AppStrings.dropdownFieldLabel(fieldLabel, displayText);

        return Semantics(
          button: true,
          label: semanticsLabel,
          hint: AppStrings.dropdownPickerHint,
          excludeSemantics: true,
          onTap: () => _openPicker(context, state),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => _openPicker(context, state),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                errorText: state.errorText,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(displayText, overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}