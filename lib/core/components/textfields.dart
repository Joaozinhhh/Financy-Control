import 'package:flutter/material.dart';


class FCTextField<T> extends TextFormField {
  FCTextField({
    super.key,
    super.style,
    super.cursorColor,
    super.onChanged,
    super.obscureText,
    super.controller,
    super.focusNode,
    super.keyboardType,
    super.textCapitalization,
    super.textInputAction,
    super.autofocus,
    super.readOnly,
    super.initialValue,
    super.validator,
    super.onTap,
    super.inputFormatters,
    super.decoration,
    super.autovalidateMode,
    super.cursorErrorColor,
  });
}

class FCCheckBoxField extends FormField<bool> {
  FCCheckBoxField({
    super.key,
    required Widget? title,
    required ValueChanged<bool?> onChanged,
    super.initialValue = false,
    super.validator,
  }) : super(
         builder: (state) {
           return CheckboxListTile(
             dense: true,
             title: title,
             checkboxShape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(5),
             ),
             value: state.value,
             onChanged: (value) {
               state.didChange(value);
               if (value != null) {
                 onChanged(value);
               }
             },
             controlAffinity: ListTileControlAffinity.leading,
           );
         },
       );
}
