import 'package:flutter/material.dart';
import 'package:heard/constants.dart';

class GreyTitleBar extends StatelessWidget {
  final String title;
  final Widget trailing;
  final int titleFlex;

  GreyTitleBar({this.title, this.trailing, this.titleFlex = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colours.grey,
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.d_20, vertical: Dimensions.d_10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: titleFlex,
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: trailing ?? SizedBox.shrink())
        ],
      ),
    );
  }
}
