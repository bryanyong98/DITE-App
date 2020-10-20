import 'package:flutter/cupertino.dart';
import 'package:heard/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen({Key key, this.topWidget}) : super(key: key);

  final Widget topWidget;

  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          topWidget != null
              ? Padding(
                  padding: EdgeInsets.only(bottom: Dimensions.d_30),
                  child: topWidget)
              : SizedBox.shrink(),
          topWidget != null ? SizedBox(height: Dimensions.d_15) : SizedBox.shrink(),
          SpinKitRing(
            color: Colours.blue,
            lineWidth: Dimensions.d_5,
          ),
          Padding(
            padding: EdgeInsets.only(top: Dimensions.d_15),
            child: Text(
              'Sedang memuatkan, sila bersabar ...',
              style: TextStyle(
                  fontSize: FontSizes.smallerText,
                  color: Colours.grey,
                  fontWeight: FontWeight.w500),
            ),
          )
        ]);
  }
}
