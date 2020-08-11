import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/cost_item.dart';
import 'package:enterprise/models/currency.dart';
import 'package:enterprise/models/income_item.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/user_grants.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
//  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final Profile profile;

  HomePage({
    this.profile
  });

  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async{
    CostItem.sync();
    IncomeItem.sync();
    Currency.sync();
    UserGrants.sync();
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
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.black])),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  actions: [
                    IconButton(
                        icon: Icon(Icons.sync),
                        onPressed: (){
                          _load();
                        },
                    )
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
                  child: GridView.count(
                    padding: EdgeInsets.all(5),
                    mainAxisSpacing: 6,
                    crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                    crossAxisSpacing: 5,
                    children: <Widget>[
                      for(var menuItems in menuList.values.toSet().where((element) => element!="default"))
                        Card(
                          color: Colors.white70,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0))),
                          child: ListTile(
                            title: Text(menuItems,  maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                            subtitle: Column(
                              children: <Widget>[
                                Container(height: 2.5, color: Colors.lightGreen, margin: EdgeInsets.all(5),),
                                for(var menuItems in menuList.keys.toList().where((element) => element.category==menuItems && element.name!="default"))
                                  InkWell(
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      child: Text(menuItems.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    ),
                                    onTap: () {
                                      RouteArgs args = RouteArgs(profile: widget.profile);
                                      Navigator.of(context).pushNamed(
                                        '${menuItems.path}',
                                        arguments: args,
                                      );
                                    },
                                  )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
