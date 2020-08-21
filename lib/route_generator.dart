import 'package:enterprise/models/models.dart';
import 'package:enterprise/pages/auth/page_auth.dart';
import 'package:enterprise/pages/auth/page_root.dart';
import 'package:enterprise/pages/auth/page_set_pin.dart';
import 'package:enterprise/pages/page_balance.dart';
import 'package:enterprise/pages/page_balance_details.dart';
import 'package:enterprise/pages/page_channel_detail.dart';
import 'package:enterprise/pages/page_coordination.dart';
import 'package:enterprise/pages/page_helpdesk_detail.dart';
import 'package:enterprise/pages/page_helpdesk.dart';
import 'package:enterprise/pages/auth/page_login.dart';
import 'package:enterprise/pages/page_home.dart';
import 'package:enterprise/pages/page_paydesk.dart';
import 'package:enterprise/pages/page_paydesk_confirm.dart';
import 'package:enterprise/pages/page_paydesk_detail.dart';
import 'package:enterprise/pages/page_analytic.dart';
import 'package:enterprise/pages/page_settings.dart';
import 'package:enterprise/pages/page_timing_hitory.dart';
import 'package:enterprise/pages/page_turnstile.dart';
import 'package:enterprise/pages/warehouse/page_orders.dart';
import 'package:enterprise/widgets/image_detail.dart';
import 'package:enterprise/widgets/open_file.dart';
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
        return MaterialPageRoute(builder: (_) => PageRoot());
      case '/home':
        if(args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => HomePage(profile: args.profile,
              ),
          );
        }
        return _errorRoute(settings.name);
      case '/timing':
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
      case '/auth':
        if (args is RouteArgs) {
          return MaterialPageRoute(
            builder: (_) => PageAuth(
              profile: args.profile,
            ),
          );
        }
        return _errorRoute(settings.name);
      case '/set_pin':
        return MaterialPageRoute(builder: (_) => PageSetPin());
      case '/image/detail':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => ImageDetail(
                listImages: args.listImage,
                initialPage: args.initialPage,
              ));
        }
        return _errorRoute(settings.name);
      case '/paydesk':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => PagePayDesk(
                    profile: args.profile,
                  ));
        }
        return _errorRoute(settings.name);
      case '/test':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => OpenFileTest(
              ));
        }
        return _errorRoute(settings.name);
      case '/paydesk/detail':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => PagePayDeskDetail(
                profile: args.profile,
                type: args.type,
                  ));
        }
        return _errorRoute(settings.name);
      case '/paydesk/confirm':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => PagePayDeskConfirm(
                profile: args.profile,
              ));
        }
        return _errorRoute(settings.name);
      case '/balance':
        if (args is RouteArgs) {
          return MaterialPageRoute(builder: (_) => PageBalance(
            profile: args.profile,
          ));
        }
        return _errorRoute(settings.name);
      case '/balance/details':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => PageBalanceDetails(
                profile: args.profile,
                currencyCode: args.currencyCode,
                inputListPayDesk: args.listDynamic,
                name: args.name,
              ));
        }
        return _errorRoute(settings.name);
      case '/results':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => PageResults(
                profile: args.profile,
              ));
        }
        return _errorRoute(settings.name);
      case '/timinghistory':
        return MaterialPageRoute(builder: (_) => PageTimingHistory());
      case '/profile':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => PageProfile(
                    profile: args.profile,
                  ));
        }
        return _errorRoute(settings.name);
      case '/coordination':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => PageCoordination(
//                    profile: args.profile,
                  ));
        }
        return _errorRoute(settings.name);
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
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => PageHelpdeskDetail(
                    profile: args.profile,
                  ));
        }
        return _errorRoute(settings.name);
      case '/helpdesk':
        if (args is RouteArgs) {
          return MaterialPageRoute(
              builder: (_) => PageHelpDesk(
                    profile: args.profile,
                  ));
        }
        return _errorRoute(settings.name);
      case '/sign_in_out':
        return MaterialPageRoute(builder: (_) => PageSignInOut());
      case '/channel/detail':
        return MaterialPageRoute(
            builder: (_) => PageChanelDetail(
                  channel: args,
                ));
      case '/warehouse/orders':
        return MaterialPageRoute(builder: (_) => PageOrders());
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
