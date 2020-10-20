import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:heard/widgets/widgets.dart';

Future<void> popUpDialog(
    {BuildContext context,
    bool isSLI,
    bool touchToDismiss = true,
    double height,
      EdgeInsets padding,
    String header = '',
    @required Widget content,
    int contentFlexValue = 1,
    String buttonText = 'Tutup',
    Function onClick}) async {
  return showDialog(
      context: context,
      barrierDismissible: touchToDismiss,
      builder: (context) {
        return Dialog(
          child: Container(
            height: height != null ? height : Dimensions.d_280,
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(
                  vertical: Dimensions.d_15, horizontal: Dimensions.d_30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(top: Dimensions.d_10),
                      child: Text(
                        header,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: FontSizes.mainTitle,
                            color: Colours.darkGrey),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: contentFlexValue,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.d_15),
                      child: content,
                    ),
                  ),
                  Flexible(
                    child: UserButton(
                        text: buttonText,
                        color: isSLI ? Colours.orange : Colours.blue,
                        onClick: onClick),
                  )
                ],
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(Dimensions.d_10))),
          elevation: Dimensions.d_15,
        );
      });
}
