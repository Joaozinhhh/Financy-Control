import 'package:flutter/material.dart';

const kFlexibleSpace = SizedBox.expand(
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: Color(0xff38b6ff),
    ),
  ),
);
const kDefaultDarkBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(32)),
  borderSide: BorderSide(color: Colors.black26),
);
const kDefaultLightBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(32)),
  borderSide: BorderSide(color: Color(0xff2b524a)),
);
const kDefaultInputDecoration = InputDecoration(
  border: kDefaultDarkBorder,
  errorBorder: kDefaultDarkBorder,
  focusedErrorBorder: kDefaultDarkBorder,
  enabledBorder: kDefaultDarkBorder,
  focusedBorder: kDefaultDarkBorder,
  disabledBorder: kDefaultDarkBorder,
  suffixIconColor: Colors.black26,
  prefixIconColor: Colors.black26,
);
const kLightDefaultInputDecoration = InputDecoration(
  border: kDefaultLightBorder,
  errorBorder: kDefaultLightBorder,
  focusedErrorBorder: kDefaultLightBorder,
  enabledBorder: kDefaultLightBorder,
  focusedBorder: kDefaultLightBorder,
  disabledBorder: kDefaultLightBorder,
  suffixIconColor: Color(0xFFFFFFFF),
  prefixIconColor: Color(0xFFFFFFFF),
);
