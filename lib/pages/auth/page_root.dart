import 'package:enterprise/database/profile_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageRoot extends StatefulWidget {
  @override
  _PageRootState createState() => _PageRootState();
}

class _PageRootState extends State<PageRoot> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initState());
  }

  _initState() async {
    final prefs = await SharedPreferences.getInstance();

    String _userID = prefs.getString(KEY_USER_ID) ?? "";
    bool _isProtectionEnabled =
        prefs.getBool(KEY_IS_PROTECTION_ENABLED) ?? false;

    if (_userID != "") {
      Profile profile = await ProfileDAO().getByUserId(_userID);

      if (profile != null) {
        RouteArgs args = RouteArgs(profile: profile);

        if (_isProtectionEnabled) {
          Navigator.of(context).pushNamed(
            "/auth",
            arguments: args,
          );
        } else {
          Navigator.of(context).pushNamed(
            "/main",
            arguments: args,
          );
        }
      } else {
        Navigator.of(context).pushNamed(
          "/sign_in_out",
          arguments: "",
        );
      }
    } else {
      Navigator.of(context).pushNamed(
        "/sign_in_out",
        arguments: "",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
