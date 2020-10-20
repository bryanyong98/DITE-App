import 'package:flutter/material.dart';
import 'package:heard/constants.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  FieldLabel({this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.d_15, left: Dimensions.d_3),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: FontSizes.normal,
            color: Colours.darkGrey),
      ),
    );
  }
}
