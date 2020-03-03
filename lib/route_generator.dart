import 'package:enterprise/models/models.dart';
import 'package:enterprise/pages/page_channel_detail.dart';
import 'package:enterprise/pages/page_helpdesk_detail.dart';
import 'package:enterprise/pages/page_helpdesk.dart';
import 'package:enterprise/pages/page_login.dart';
import 'package:enterprise/pages/page_paydesk.dart';
import 'package:enterprise/pages/page_settings.dart';
import 'package:enterprise/pages/page_timing_hitory.dart';
import 'package:enterprise/pages/page_turnstile.dart';
import 'package:enterprise/pages/warehouse/goods/page_goods_list.dart';
import 'package:enterprise/pages/warehouse/page_orders.dart';
import 'package:flutter/material.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:enterprise/pages/page_profile.dart';
import 'package:enterprise/pages/page_debug.dart';
import 'package:enterprise/pages/page_about.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        if (args is RouteArgs) {
          return MaterialPageRoute(
            builder: (_) => PageMain(
              profile: args.profile,
            ),
          );
        }
//        return _errorRoute(settings.name);
        return MaterialPageRoute(
            builder: (_) => PageMain(
                  profile: null,
                ));
      case '/paydesk':
        return MaterialPageRoute(builder: (_) => PagePayDesk());
      case '/timinghistory':
        return MaterialPageRoute(builder: (_) => PageTimingHistory());
      case '/profile':
        return MaterialPageRoute(builder: (_) => PageProfile());
      case '/settings':
        if (args is RouteArgs) {
          return MaterialPageRoute(
            builder: (_) => PageSettings(
              profile: args.profile,
            ),
          );
        }
        return _errorRoute(settings.name + " worng args type");
      case '/debug':
        return MaterialPageRoute(builder: (_) => PageDebug());
      case '/about':
        return MaterialPageRoute(builder: (_) => PageAbout());
      case '/turnstile':
        return MaterialPageRoute(builder: (_) => PageTurnstile());
      case '/helpdeskdetail':
        return MaterialPageRoute(builder: (_) => PageHelpdeskNew());
      case '/helpdesk':
        return MaterialPageRoute(builder: (_) => PageHelpdesk());
      case '/sign_in_out':
        return MaterialPageRoute(builder: (_) => PageSignInOut());
      case '/channel/detail':
        return MaterialPageRoute(
            builder: (_) => PageChanelDetail(
                  channel: args,
                ));
      case '/warehouse/orders':
        return MaterialPageRoute(builder: (_) => PageOrders());
      case '/warehouse/goods/list':
        return MaterialPageRoute(builder: (_) => PageGoodsList());
      // Validation of correct data type
//        if (args is String) {
//          return MaterialPageRoute(
//            builder: (_) => PageSettings(
//              data: args,
//            ),
//          );
//        }
      // If args is not of the correct type, return an error page.
      // You can also throw an exception while in development.
//        return _errorRoute();
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String route) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR route: $route)'),
        ),
      );
    });
  }
}
