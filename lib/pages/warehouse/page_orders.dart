
import 'package:enterprise/database/warehouse/documents_dao.dart';
import 'package:enterprise/database/warehouse/goods_dao.dart';
import 'package:enterprise/database/warehouse/partners_dao.dart';
import 'package:enterprise/database/warehouse/relation_documents_goods_dao.dart';
import 'package:enterprise/database/warehouse/user_goods_dao.dart';
import 'package:enterprise/models/warehouse/documnets.dart';
import 'package:enterprise/models/warehouse/goods.dart';
import 'package:enterprise/models/warehouse/partners.dart';
import 'package:enterprise/models/warehouse/relation_documents_goods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'page_documents_controller.dart';
import 'page_goods_controller.dart';
import 'page_partners_controller.dart';

class PageOrders extends StatefulWidget {
  @override
  _PageOrdersState createState() => _PageOrdersState();
}

class _PageOrdersState extends State<PageOrders> with SingleTickerProviderStateMixin {
  Future<List<Documents>> _documentsList;
  Future<List<Goods>> _goodsList;
  Future<List<Goods>> _goodsAddedList;
  Future<List<Partners>> _partnersList;
  Future<List<RelationDocumentsGoods>> _relationsList;

  TabController _tabController;

  bool _isVisible;
  bool _isSort = true;

  List<Goods> _sortedList = [];

  final List<Tab> _myTabs = <Tab>[
    Tab(text: 'Список замовлень'),
    Tab(text: 'Список номенклатур'),
    Tab(text: 'Номенклатура постачальника'),
    Tab(text: 'Партнери',),
  ];

  @override
  void initState() {
    super.initState();
    _isVisible = true;
    _tabController = TabController(vsync: this, length: _myTabs.length);
    _tabController.addListener(() {
      setState(() {
        if(_tabController.index <= 1 && !_isVisible){
          _isVisible = true;
        } else if(_tabController.index >= 2 && _isVisible) {
          _isVisible = false;
        }
      });
    });
    _goodsList = GoodsDAO().getAll();
    _goodsAddedList = UserGoodsDAO().getAll();
    _relationsList = RelationDocumentsGoodsDAO().getAll();
    _documentsList = _setGoodsToDocuments(DocumentsDAO().getAll(),
        _relationsList,
        _goodsAddedList);
    _partnersList = PartnersDAO().getAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
        length: _tabController.length,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                    title: Text('Склад'),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: _CustomSearchDelegate(_tabController),
                          );
                        },
                      ),
                    ],
                    pinned: true,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                    bottom: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabs: _myTabs
                    )
                ),
              ];
            },
            body: TabBarView(
                controller: _tabController,
                children: [
                  _documents(_documentsList),
                  _goods(_goodsAddedList, true),
                  _goods(_goodsList, false),
                  _partners(_partnersList),
                ]
            ),
          ),
          floatingActionButton: Visibility(
              visible: _isVisible,
              child: FloatingActionButton(
                onPressed: () {
                  switch(_tabController.index) {
                    case 0:
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return DocumentsView(
                          currentDocument: Documents(),
                          enableEdit: true,
                          partnersList: _partnersList,
                          goodsList: _goodsAddedList,
                        );
                      })).whenComplete(() => _load("documents"));
                      break;
                    case 1:
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return GoodsView(
                          currentGood: Goods(),
                          enableEdit: true,
                          isNew: false,
                          goodsList: _goodsList,
                        );
                      })).whenComplete(() => _load("goodsAdded"));
                      break;
                    default:
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return DocumentsView(
                          currentDocument: Documents(),
                          enableEdit: true,
                          partnersList: _partnersList,
                          goodsList: _goodsAddedList,
                        );
                      })).whenComplete(() => _load("documents"));
                      break;
                  }
                },
                child: Icon(Icons.add),
              )
          ),
        )
    );
  }

  Future<List<Documents>> _setGoodsToDocuments( //Set Goods to Document from
      Future<List<Documents>> inputDocuments,   //Relations
      Future<List<RelationDocumentsGoods>> inputRelations,
      Future<List<Goods>> inputGoods){
    inputDocuments.then((documents) =>
        inputGoods.then((goods) =>
            inputRelations.then((relations) =>
                relations.forEach((relation) {
                  documents.elementAt(relation.documentID-1)
                      .goods.add(goods.where(
                          (good) => good.mobID == relation.goodsID)
                      .toList().first);
                }
                )
            )
        ));
    return inputDocuments;
  }

  Widget _documents(Future<List<Documents>> documentsList){
    return FutureBuilder<List<Documents>>(
      future: documentsList,
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
            return Center(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data == null
                    ? 0
                    : snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Documents _documents = snapshot.data[index];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return DocumentsView(
                          currentDocument: _documents,
                          enableEdit: false,
                          partnersList: _partnersList,
                          goodsList: _goodsAddedList,
                        );
                      })).whenComplete(() => _load("documents"));
                    },
                    child: Hero(
                        tag: 'document_${_documents.mobID}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                              height: 220.0,
                              margin: EdgeInsets.all(10.0),
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius
                                    .all(Radius.circular(20.0)),
                                color: Colors.grey[300],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('№ ${_documents.number}',
                                        style: TextStyle(fontSize: 17.0),),
                                      Text('${_documents.partner}',
                                        style: TextStyle(fontSize: 17.0),),
                                      Row(
                                        children: <Widget>[
                                          Text('${DateFormat('dd.MM.yyyy')
                                              .format(_documents.date)}',
                                            style: TextStyle(fontSize: 14.0,
                                                color: Colors.grey),),
                                          Opacity(
                                            opacity: 0.2,
                                            child: Icon(Icons.arrow_forward_ios),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Text("${_documents.status
                                      ? 'Робочий'
                                      : 'Чорновик'}",
                                    style: TextStyle(fontSize: 15.0 ,
                                        color: _documents.status
                                            ? Colors.green
                                            : Colors.blue[800]),
                                  ),
                                  SizedBox(height: 5,),
                                  Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _documents.goods == null
                                          ? 0
                                          : _documents.goods.length,
                                      shrinkWrap: true,
                                      itemBuilder: (BuildContext context, int index) {
                                        Goods _good = _documents.goods[index];
                                        return Card(
                                          color: Colors.grey[200],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.only(top: 10,
                                                bottom: 10,
                                                right: 5,
                                                left: 5),
                                            child: Column(
                                              children: <Widget>[
                                                Text("Назва:",
                                                    style: TextStyle(fontSize: 15.0)),
                                                Text(_good.name,
                                                  style: TextStyle(color: Colors.grey[600]),),
                                                Text("\nКiлькiсть:",
                                                    style: TextStyle(fontSize: 15.0)),
                                                Text("${_good.count}, ${_good.unit}",
                                                  style: TextStyle(color: Colors.grey[600]),),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                          ),
                        )
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
    );
  }

  Widget _goods(Future<List<Goods>> goodsList, bool isNew){
    return FutureBuilder<List<Goods>>(
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
            List<DataRow> dataRows = [];
            if(_sortedList!=null ? _sortedList.length!=snapshot.data.length : false){
              _sortedList = [];
              snapshot.data.forEach((good) {
                _sortedList.add(good);
              });
            }
            _sortedList.forEach((good) {
              dataRows.add(
                  DataRow(
                      cells: <DataCell> [
                        DataCell(Text(good.name),
                            showEditIcon: true,
                            onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (_){
                            return GoodsView(
                              currentGood: good,
                              enableEdit: false,
                              isNew: !isNew,
                              goodsList: this._goodsList,
                            );
                          })).whenComplete(() => _load("goodsAdded"));
                        }),
                        DataCell(Text(good.unit)),
                        DataCell(Text('${good.count}')),
                      ])
              );
            });
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 20.0,
                sortColumnIndex: this.context == null || !isNew
                    ? null
                    : 2,
                sortAscending: _isSort,
                columns: [
                  DataColumn(
                    label: Text('Назва'),
                    tooltip: 'Назва номенклатури',
                  ),
                  DataColumn(
                    label: Text('Од. вимiру', softWrap: true,),
                    tooltip: 'Одиницi вимiру',
                  ),
                  DataColumn(
                    numeric: true,
                    label: Text('Кiлькiсть'),
                    tooltip: _isSort ? 'Вiд меньшого'
                        : 'Вiд бiльшого',
                    onSort: (i, b) {
                      if(this.context!=null && isNew){
                        setState(() {
                          if(_isSort){
                            _sortedList.sort((firstGood, secondGood) =>
                                secondGood.count.compareTo(firstGood.count));
                            _isSort = false;
                          } else {
                            _sortedList.sort((firstGood, secondGood) =>
                                firstGood.count.compareTo(secondGood.count));
                            _isSort = true;
                          }
                        });
                      }
                    },
                  )
                ],
                rows: dataRows,
              ),
            );
          default:
            return Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );

  }

  Widget _partners(Future<List<Partners>> partnersList){
    return FutureBuilder<List<Partners>>(
      future: partnersList,
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
            return Center(
              child: ListView.builder(
                itemCount: snapshot.data == null
                    ? 0
                    : snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Partners _partners = snapshot.data[index];
//                 var _image = Image.file(_partners.logo);
//                 Add image of partner to list
//                 Surround with try{} catch for handle the error
//                 Add field 'logo' to => warehouse core, partners_dao and models partners
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return PartnersView(
                          currentPartners: _partners,
                        );
                      }));
                    },
                    child: Hero(
                        tag: 'partner_${_partners.mobID}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${_partners.mobID}'),
//                             child:  _image == null
//                              ? Text(_id)
//                              : _image,
//                             Check if partner have image, show image, else show id
                            ),
                            title: Text(_partners.name),
                          ),
                        )
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
    );
  }

  void _load(String toUpdate) {
    if(context != null)
      setState(() {
        switch(toUpdate){
          case "documents":
            _relationsList = RelationDocumentsGoodsDAO().getAll();
            _goodsAddedList = UserGoodsDAO().getAll();
            _documentsList = _setGoodsToDocuments(DocumentsDAO().getAll(),
                _relationsList,
                _goodsAddedList);
            _partnersList = PartnersDAO().getAll();
            break;
          case "goodsAdded":
            _sortedList = [];
            _goodsAddedList = UserGoodsDAO().getAll();
            _relationsList = RelationDocumentsGoodsDAO().getAll();
            _documentsList = _setGoodsToDocuments(DocumentsDAO().getAll(),
                _relationsList,
                _goodsAddedList);
            _goodsList = GoodsDAO().getAll();
            _partnersList = PartnersDAO().getAll();
            break;
          default:
            _goodsList = GoodsDAO().getAll();
            _goodsAddedList = UserGoodsDAO().getAll();
            _relationsList = RelationDocumentsGoodsDAO().getAll();
            _documentsList = _setGoodsToDocuments(DocumentsDAO().getAll(),
                _relationsList,
                _goodsAddedList);
            _partnersList = PartnersDAO().getAll();
        }
      });
  }

}

class _CustomSearchDelegate extends SearchDelegate {

  final TabController _tabController;
  _CustomSearchDelegate(this._tabController);

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
    if (query.length < 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Для пошуку введіть бiльше однієї лiтери",
            ),
          )
        ],
      );
    }

    switch (_tabController.index){
      case 0:
        Future<List<Documents>> _listDocuments = DocumentsDAO().search(query);
        return _PageOrdersState()._documents(_listDocuments);
        break;
      case 1:
        Future<List<Goods>> _listAddedGoods = UserGoodsDAO().search(query);
        return _PageOrdersState()._goods(_listAddedGoods, true);
        break;
      case 2:
        Future<List<Goods>> _listGoods = GoodsDAO().search(query);
        return _PageOrdersState()._goods(_listGoods, false);
        break;
      case 3:
        Future<List<Partners>> _listGoods = PartnersDAO().search(query);
        return _PageOrdersState()._partners(_listGoods);
        break;
      default:
        Future<List<Documents>> _listDocuments = DocumentsDAO().search(query);
        return _PageOrdersState()._documents(_listDocuments);
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called every time the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Center();
  }

}
