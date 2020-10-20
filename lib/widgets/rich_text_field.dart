import 'package:flutter/material.dart';
import 'package:heard/constants.dart';

class RichTextField extends StatelessWidget {

  final String labelText;
  final String data;

  RichTextField(this.labelText, this.data);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text:TextSpan(
        style: new TextStyle(
          fontSize: FontSizes.normal,
          color: Colours.black,
        ),
        children: <TextSpan>[
          TextSpan(
              text: '$labelText: ',
              style: new TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: '$data',
          )
        ],
      ),
    );
  }
}
