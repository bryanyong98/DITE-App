import 'package:flutter/material.dart';
import 'package:heard/constants.dart';

class DropdownList extends StatelessWidget {

  final String hintText;
  final String selectedItem;
  final Function onChanged;
  final List <DropdownMenuItem <String>> itemList;
  final bool isExpanded;
  final bool noColour;
  final EdgeInsets padding;

  DropdownList({this.hintText, this.selectedItem,this.itemList, this.onChanged, this.isExpanded = true, this.noColour = false, this.padding});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
          color: !noColour ? Colours.lightBlue : Colours.white,
          borderRadius:
          BorderRadius.all(Radius.circular(Dimensions.d_10))
      ),
      child: Padding(
        padding: padding == null ? EdgeInsets.symmetric(horizontal: Dimensions.d_15, vertical: Dimensions.d_3) : padding,
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
              isExpanded: isExpanded,
              value: selectedItem,
              items: itemList,
              hint: new Text(hintText),
              iconSize: Dimensions.d_30,
              onChanged: onChanged,
             ),
        ),
      ),
    );
  }
}
