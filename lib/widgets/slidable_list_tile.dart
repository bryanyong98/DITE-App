import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:heard/constants.dart';

class SlidableListTile extends StatelessWidget {
  final SlideActionBuilderDelegate slideLeftActionFunctions;
  final SlideActionBuilderDelegate slideRightActionFunctions;
  final Widget onTrailingButtonPress;
  final Widget profilePicture;
  final Color tileColour;
  final Widget title;
  final Widget subtitle;
  final Function onDismissed;

  SlidableListTile({this.slideLeftActionFunctions, this.profilePicture, this.slideRightActionFunctions, this.onTrailingButtonPress, this.tileColour, this.title, this.subtitle, this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          color: tileColour != null ? tileColour : Colours.white,
          child: Slidable.builder(
            key: UniqueKey(),
            dismissal: SlidableDismissal(
              dragDismissible: false,
              onDismissed: onDismissed,
              child: SlidableDrawerDismissal(),
            ),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: ListTile(
              contentPadding: EdgeInsets.all(Dimensions.d_20),
              isThreeLine: true,
              leading: CircleAvatar(
                backgroundColor: Colours.lightGrey,
                radius: Dimensions.d_35,
                child: profilePicture ?? Image(
                    image: AssetImage('images/avatar.png')),
              ),
              title: title,
              subtitle: subtitle,
              trailing: onTrailingButtonPress != null ? onTrailingButtonPress : SizedBox.shrink(),
            ),
            actionDelegate: slideRightActionFunctions,
            secondaryActionDelegate: slideLeftActionFunctions,
          ),
        ),
        Divider(
          height: Dimensions.d_0,
          thickness: Dimensions.d_3,
          color: Colours.lightGrey,
        )
      ],
    );
  }
}
