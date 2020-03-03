import 'package:enterprise/database/warehouse/goods_dao.dart';
import 'package:enterprise/models/warehouse/goods.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:flutter/material.dart';

class PageGoodsList extends StatefulWidget {
  @override
  _PageGoodsListState createState() => _PageGoodsListState();
}

class _PageGoodsListState extends State<PageGoodsList> {
  Future<List<Goods>> goodsList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    goodsList = _getGoodsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Номенклатура'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        profile: null,
      ),
      body: GoodsListView(
        goodsList: goodsList,
      ),
//      Container(
//        child: FutureBuilder(
//          future: goodsList,
//          builder: (BuildContext context, AsyncSnapshot snapshot) {
//            switch (snapshot.connectionState) {
//              case ConnectionState.none:
//                return Center(
//                  child: CircularProgressIndicator(),
//                );
//              case ConnectionState.waiting:
//                return Center(
//                  child: CircularProgressIndicator(),
//                );
//              case ConnectionState.active:
//                return Center(
//                  child: CircularProgressIndicator(),
//                );
//              case ConnectionState.done:
//                var _goodsList = snapshot.data;
//                return Center(
//                  child: ListView.builder(
//                    itemCount: _goodsList.length,
//                    itemBuilder: (BuildContext context, int index) {
//                      Goods _goods = _goodsList[index];
//                      return Container(
//                        padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
//                        child: Card(
//                          child: Container(
//                            margin: EdgeInsets.all(5.0),
//                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Text(
//                                  _goods.name,
//                                  style: TextStyle(fontSize: 18.0),
//                                ),
//                              ],
//                            ),
//                          ),
//                        ),
//                      );
//                    },
//                  ),
//                );
//              default:
//                return Center(
//                  child: CircularProgressIndicator(),
//                );
//            }
//          },
//        ),
//      ),
    );
  }

  Future<List<Goods>> _getGoodsList() {
    return GoodsDAO().getAll();
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Для пошуку введіть більше 2ох літер",
            ),
          )
        ],
      );
    }

    Future<List<Goods>> goodsList = GoodsDAO().getByName(query);

    return GoodsListView(
      goodsList: goodsList,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }
}

class GoodsListView extends StatelessWidget {
  final Future<List<Goods>> goodsList;

  GoodsListView({
    this.goodsList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: goodsList,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              var _goodsList = snapshot.data;
              return Center(
                child: ListView.builder(
                  itemCount: _goodsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Goods _goods = _goodsList[index];
                    return Container(
                      padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      child: Card(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _goods.name,
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            default:
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
