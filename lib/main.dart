import 'package:enterprise/models.dart';
import 'package:flutter/material.dart';
import 'package:enterprise/route_generator.dart';

void main() => runApp(EnterpriseApp());

class EnterpriseApp extends StatefulWidget {
  EnterpriseAppState createState() => EnterpriseAppState();
}

class EnterpriseAppState extends State<EnterpriseApp> {
  void initState() {
    Timing.closePastOperation();
    Timing.clearCurrentOperation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

//class MainBottomNavigationBar extends StatelessWidget {
//  const MainBottomNavigationBar(
//    this.currentPage, {
//    Key key,
//  })  : assert(
//          currentPage != null,
//          'A non-null String must be provided to a MainBottomNavigationBar widget.',
//        ),
//        super(key: key);
//
//  final String currentPage;
//
//  int getPageIndex(String currentPage) {
//    switch (currentPage) {
//      case "/":
//        return 0;
//      case "/chanel":
//        return 1;
//      case "/profile":
//        return 2;
//      case "/settings":
//        return 3;
//      default:
//        return 0;
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return BottomNavigationBar(
//      currentIndex: getPageIndex(currentPage),
//      type: BottomNavigationBarType.fixed,
//      onTap: (index) {
//        switch (index) {
//          case 0:
//            Navigator.of(context).pushNamed(
//              '/',
//              arguments: currentPage,
//            );
//            break;
//          case 1:
//            Navigator.of(context).pushNamed(
//              '/chanel',
//              arguments: currentPage,
//            );
//            break;
//          case 2:
//            Navigator.of(context).pushNamed(
//              '/profile',
//              arguments: currentPage,
//            );
//            break;
//          case 3:
//            Navigator.of(context).pushNamed(
//              '/settings',
//              arguments: currentPage,
//            );
//            break;
//          default:
//            Navigator.of(context).pushNamed(
//              '/',
//              arguments: currentPage,
//            );
//        }
//      },
//      items: [
//        BottomNavigationBarItem(
//          icon: Icon(Icons.home),
//          title: Text('головна'),
//        ),
//        BottomNavigationBarItem(
//          icon: Icon(Icons.rss_feed),
//          title: Text('канал'),
//        ),
//        BottomNavigationBarItem(
//          icon: Icon(Icons.person),
//          title: Text('профіль'),
//        ),
//        BottomNavigationBarItem(
//          icon: Icon(Icons.settings),
//          title: Text('налаштування'),
//        )
//      ],
//    );
//  }
//}
