import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class PageAbout extends StatefulWidget {
  PageAboutState createState() => PageAboutState();
}

class PageAboutState extends State<PageAbout> {
  PackageInfo packageInfo;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initWidget());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'INTELLECT-CASE',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://intellectcase.com/');
                      },
                  ),
                ],
              ),
            ),
            Text('version: ' + packageInfo?.version)
          ],
        ),
      ),
    );
  }

  initWidget() async {
    PackageInfo _packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      packageInfo = _packageInfo;
    });
  }
}
