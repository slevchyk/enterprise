import 'package:flutter/material.dart';

class IconWithNotification extends StatelessWidget {
  final IconData iconData;
  final String text;
  final VoidCallback onTap;
  final int notificationCount;
  final Color circleColor;
  final BoxShape boxShape;

  const IconWithNotification({
    Key key,
    this.onTap,
    this.text,
    @required this.iconData,
    this.notificationCount,
    this.circleColor = Colors.red,
    this.boxShape = BoxShape.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 45,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData),
                text != null
                    ? Text(text, overflow : TextOverflow.ellipsis)
                    : Container(),
              ],
            ),
            notificationCount != 0
                ? Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                decoration: BoxDecoration(shape: boxShape, color: circleColor),
                alignment: Alignment.center,
                child: Text('$notificationCount'),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}