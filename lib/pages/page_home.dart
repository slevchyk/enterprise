import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/currency.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/menu.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/user_grants.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Profile profile;

  HomePage({this.profile});

  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (await CostItem.sync() && await IncomeItem.sync() && await Currency.sync() && await UserGrants.sync()) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Даннi оновлено"),
        backgroundColor: Colors.green,
      ));
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Помилка оновлення даних"),
        backgroundColor: Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        profile: widget.profile,
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, orientation) {
          return Container(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  actions: [
                    IconButton(
                      icon: Icon(Icons.sync),
                      onPressed: () {
                        _load();
                      },
                    ),
                  ],
                  leading: MaterialButton(
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    child: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                  title: Text('Головна'),
                  pinned: true,
                  floating: false,
                ),
                SliverFillRemaining(
                  child: ListView.builder(
                    padding: EdgeInsets.only(),
                    itemCount: menuList.values.toSet().where((element) => element != "default").length,
                    itemBuilder: (BuildContext context, int index) {
                      List<String> _menuCategoryList =
                          menuList.values.toSet().where((element) => element != "default").toList();
                      return Card(
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  _menuCategoryList.elementAt(index),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                ),
                              ),
                              Container(
                                height: 0.5,
                                color: Colors.grey,
                                margin: EdgeInsets.all(5),
                              ),
                              Container(
                                height: orientation == Orientation.portrait
                                    ? index == 0 ? 210 : 150
                                    : index == 0 ? 300 : 220,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: menuList.keys
                                        .toList()
                                        .where((element) =>
                                            element.category == _menuCategoryList.elementAt(index) &&
                                            element.name != "default")
                                        .length,
                                    itemBuilder: (BuildContext context, int indexItems) {
                                      List<MenuItem> _menuItemsList = menuList.keys
                                          .toList()
                                          .where((element) =>
                                              element.category == _menuCategoryList[index] && element.name != "default")
                                          .toList();
                                      return Column(
                                        children: [
                                          Container(
                                            height: orientation == Orientation.portrait ? 110 : 180,
                                            width: orientation == Orientation.portrait ? 110 : 180,
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.grey[100],
                                              boxShadow: [
                                                BoxShadow(color: Colors.lightGreen, spreadRadius: 1),
                                              ],
                                            ),
                                            child: Center(
                                              child: ListTile(
                                                onTap: () {
                                                  RouteArgs args = RouteArgs(profile: widget.profile);
                                                  Navigator.of(context).pushNamed(
                                                    '${_menuItemsList[indexItems].path}',
                                                    arguments: args,
                                                  );
                                                },
                                                title: Column(
                                                  children: [
                                                    _menuItemsList[indexItems].icon,
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      _menuItemsList[indexItems].name,
                                                      textAlign: TextAlign.center,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: orientation == Orientation.portrait ? 15 : 22,
                                                          color: Colors.black54),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          index == 0
                                              ? Padding(
                                                  padding: EdgeInsets.only(top: 10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(30),
                                                      color: Colors.lightGreen,
                                                      boxShadow: [
                                                        BoxShadow(color: Colors.lightGreen, spreadRadius: 1),
                                                      ],
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        RouteArgs _args = RouteArgs(
                                                            profile: widget.profile, type: _setType(indexItems));
                                                        Navigator.pushNamed(context, "/paydesk/detail",
                                                            arguments: _args);
                                                      },
                                                      icon: Icon(
                                                        _setIcon(indexItems),
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      );
                                    }),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _setIcon(int index) {
    switch (index) {
      case 0:
        return Icons.add;
      case 1:
        return Icons.remove;
      case 2:
        return Icons.compare_arrows;
      default:
        return Icons.add;
    }
  }

  PayDeskTypes _setType(int index) {
    switch (index) {
      case 0:
        return PayDeskTypes.costs;
      case 1:
        return PayDeskTypes.income;
      case 2:
        return PayDeskTypes.transfer;
      default:
        return PayDeskTypes.costs;
    }
  }
}
