import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckBoxTile extends StatefulWidget {
  final bool value;
  final Function onChanged;
  final String text;
  final String textLink;
  final String textLinkURL;
  final EdgeInsetsGeometry padding;

  CheckBoxTile(
      {this.onChanged,
        this.value,
        this.text,
        this.textLink,
        this.textLinkURL,
        this.padding});

  @override
  _CheckBoxTileState createState() => _CheckBoxTileState();
}

class _CheckBoxTileState extends State<CheckBoxTile> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.all(0),
      value: widget.value,
      onChanged: widget.onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      title: Padding(
        padding: widget.padding ?? EdgeInsets.all(Dimensions.d_0),
        child: RichText(
          text: TextSpan(
              children: [
                TextSpan(
                  text: widget.text,
                  style: GoogleFonts.lato(
                      color: Colours.darkGrey,
                      fontSize: FontSizes.smallerText,
                      fontWeight: FontWeight.w600)
                ),
                TextSpan(
                  text: widget.textLink,
                  style: GoogleFonts.lato(
                      color: Colours.darkBlue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      fontSize: FontSizes.smallerText),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      /// todo: add url link for terms and conditions
//                  launch(widget.textLinkURL);
                    },
                )
              ]
          ),
        ),
      ),
    );
  }
}