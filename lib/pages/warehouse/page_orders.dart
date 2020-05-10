
import 'package:barcode_scan/barcode_scan.dart';
import 'package:enterprise/database/warehouse/goods_dao.dart';
import 'package:enterprise/database/warehouse/impl/documents_dao.dart';
import 'package:enterprise/database/warehouse/impl/supply_documents_dao.dart';
import 'package:enterprise/database/warehouse/partners_dao.dart';
import 'package:enterprise/database/warehouse/user_goods_dao.dart';
import 'package:enterprise/models/warehouse/documnets.dart';
import 'package:enterprise/models/warehouse/goods.dart';
import 'package:enterprise/models/warehouse/partners.dart';
import 'package:enterprise/models/warehouse/supply_documnets.dart';
import 'package:enterprise/pages/warehouse/page_supply_documents_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'page_documents_controller.dart';
import 'page_goods_controller.dart';
import 'page_partners_controller.dart';

class PageOrders extends StatefulWidget {
  @override
  _PageOrdersState createState() => _PageOrdersState();
}

class _PageOrdersState extends State<PageOrders> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Documents>> _documentsList;
  Future<List<Goods>> _goodsList;
  Future<List<SupplyDocuments>> _supplyDocumentsList;
  Future<List<Goods>> _goodsAddedList;
  Future<List<Partners>> _partnersList;

  TabController _tabController;

  bool _isVisible;
  bool _isSort = true;

  List<Goods> _sortedList = [];

  final List<Tab> _myTabs = <Tab>[
    Tab(text: 'Список замовлень'),
    Tab(text: 'Список номенклатур'),
    Tab(text: 'Прихiд постачальника'),
    Tab(text: 'Номенклатура постачальника'),
    Tab(text: 'Партнери'),
  ];

  @override
  void initState() {
    super.initState();
    _isVisible = true;
    _tabController = TabController(vsync: this, length: _myTabs.length);
    _tabController.addListener(() {
      setState(() {
        if(_tabController.index <= 2 && !_isVisible){
          _isVisible = true;
        } else if(_tabController.index >= 3 && _isVisible) {
          _isVisible = false;
        }
      });
    });
    _load(_ToUpdate.defaultUpdate);
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
          key: _scaffoldKey,
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                    title: Text('Склад'),
                    actions: <Widget>[
                      _tabController.index == 0 || _tabController.index == 2 ?
                      IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () async {
                            String scan = await _scan();
                            int _id = _getID(scan);
                            int _last;
                            _tabController.index == 0 ?
                                _last = await UserGoodsDAO().getLastId() :
                                _last = await GoodsDAO().getLastId();
                            if(_id == 0 || _last<=_id) {
                              _scaffoldKey.currentState.showSnackBar(
                                  SnackBar(
                                    content: Text('Номенклатуру не знайдено'),
                                    backgroundColor: Colors.red,));
                              return null;
                            }
                            var _searchResponse;
                            _tabController.index == 0 ?
                                _searchResponse = ImplDocumentsDAO().getDocumentByGoodsID(_id) :
                                _searchResponse = ImplSupplyDocumentsDAO().getDocumentByGoodsID(_id);
                            Goods _good;
                            _tabController.index == 0 ?
                                _good = await UserGoodsDAO().getById(_id) :
                                _good = await GoodsDAO().getById(_id);

                            bool _empty;
                            await _searchResponse.then((value) => _empty = value.isEmpty);

                            return Navigator.push(context, MaterialPageRoute(
                                builder: (_) {return Scaffold(
                                  appBar: AppBar(
                                    title: Text("Пошук по: ${_good.name}",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                    actions: <Widget>[
                                      IconButton(
                                          icon: Icon(Icons.info),
                                          onPressed: () {
                                            showGeneralDialog(
                                              barrierLabel: 'info_goods_search',
                                              barrierDismissible: true,
                                              barrierColor: Colors.black.withOpacity(0.5),
                                              transitionDuration: Duration(milliseconds: 250),
                                              context: _scaffoldKey.currentContext,
                                              transitionBuilder: (context, anim1, anim2, child) {
                                                return SlideTransition(
                                                  position: Tween(
                                                      begin: Offset(0, -1),
                                                      end: Offset(0, 0)).animate(anim1),
                                                  child: child,
                                                );
                                              },
                                              pageBuilder: (context, anim1, anim2) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(20.0))
                                                ),
                                                insetPadding: EdgeInsets.only(top: 200, bottom: 200),
                                                content: ListTile(
                                                  title: Text("Iнформацiя про номенклатуру \n\n${_good.name}"),
                                                  subtitle: Text("Кiлькiсть - ${_good.count}, "
                                                        "${_good.unit}"),
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('Назад'),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                      )
                                    ],
                                  ),
                                  body: GestureDetector(
                                    onDoubleTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: _empty ?
                                        Container(
                                          child: Center(
                                            child: Text("Документiв з данною номенклатурою не знайдено"),
                                          ),) :
                                        _tabController.index == 0 ?
                                            _PageOrdersState()._documents(_searchResponse) :
                                            _PageOrdersState()._supplyDocuments(_searchResponse),
                                  )
                                );}));
                            },
                      ) : Container(),
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
                  _supplyDocuments(_supplyDocumentsList),
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
                        );
                      })).whenComplete(() => _load(_ToUpdate.documents));
                      break;
                    case 1:
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return GoodsView(
                          currentGood: Goods(),
                          enableEdit: true,
                          isNew: false,
                        );
                      })).whenComplete(() => _load(_ToUpdate.goods));
                      break;
                    case 2:
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return SupplyDocumentsView(
                          currentSupplyDocument: SupplyDocuments(),
                          enableEdit: true,
                        );
                      })).whenComplete(() => _load(_ToUpdate.supplyDocuments));
                      break;
                    default:
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return DocumentsView(
                          currentDocument: Documents(),
                          enableEdit: true,
                        );
                      })).whenComplete(() => _load(_ToUpdate.documents));
                      break;
                  }
                },
                child: Icon(Icons.add),
              )
          ),
        )
    );
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
                itemCount: snapshot.data == null ?
                    0 :
                    snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Documents _documents = snapshot.data[index];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return DocumentsView(
                          currentDocument: _documents,
                          enableEdit: false,
                        );
                      })).whenComplete(() => _load(_ToUpdate.documents));
                    },
                    child: Hero(
                        tag: 'document_${_documents.mobID}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                              height: 230.0,
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

  Widget _supplyDocuments(Future<List<SupplyDocuments>> supplyDocumentsList){
    return FutureBuilder<List<SupplyDocuments>>(
      future: supplyDocumentsList,
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
                  SupplyDocuments _supplyDocuments = snapshot.data[index];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return SupplyDocumentsView(
                          currentSupplyDocument: _supplyDocuments,
                          enableEdit: false,
                        );
                      })).whenComplete(() => _load(_ToUpdate.supplyDocuments));
                    },
                    child: Hero(
                        tag: 'supplyDocuments_${_supplyDocuments.mobID}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                              height: 240.0,
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
                                      Text('№ ${_supplyDocuments.number}',
                                        style: TextStyle(fontSize: 17.0),),
                                      Text('${_supplyDocuments.partner}',
                                        style: TextStyle(fontSize: 17.0),),
                                      Row(
                                        children: <Widget>[
                                          Text('${DateFormat('dd.MM.yyyy')
                                              .format(_supplyDocuments.date)}',
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
                                  Text("${_supplyDocuments.status
                                      ? 'Робочий'
                                      : 'Чорновик'}",
                                    style: TextStyle(fontSize: 15.0 ,
                                        color: _supplyDocuments.status
                                            ? Colors.green
                                            : Colors.blue[800]),
                                  ),
                                  SizedBox(height: 5,),
                                  Text('Кiлькiсть: ${_supplyDocuments.count}'),
                                  SizedBox(height: 5,),
                                  Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _supplyDocuments.goods == null
                                          ? 0
                                          : _supplyDocuments.goods.length,
                                      shrinkWrap: true,
                                      itemBuilder: (BuildContext context, int index) {
                                        Goods _good = _supplyDocuments.goods[index];
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
                            );
                          })).whenComplete(() => _load(_ToUpdate.goods));
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

  void _load(_ToUpdate update) {
    if(context != null)
      setState(() {
        switch(update){
          case _ToUpdate.documents:
            _goodsAddedList = UserGoodsDAO().getAll();
            _documentsList = ImplDocumentsDAO().getAll();
            _partnersList = PartnersDAO().getAll();
            break;
          case _ToUpdate.goods:
            _sortedList = [];
            _goodsAddedList = UserGoodsDAO().getAll();
            _documentsList = ImplDocumentsDAO().getAll();
            _goodsList = GoodsDAO().getAll();
            _partnersList = PartnersDAO().getAll();
            break;
          case _ToUpdate.supplyDocuments:
            _goodsList = GoodsDAO().getAll();
            _supplyDocumentsList = ImplSupplyDocumentsDAO().getAll();
            break;
          default:
            _goodsList = GoodsDAO().getAll();
            _goodsAddedList = UserGoodsDAO().getAll();
            _documentsList = ImplDocumentsDAO().getAll();
            _supplyDocumentsList = ImplSupplyDocumentsDAO().getAll();
            _partnersList = PartnersDAO().getAll();
        }
      });
  }

  Future<String> _scan() async {
    try{
      return await BarcodeScanner.scan();
    } on PlatformException catch(e){
      if(e.code == BarcodeScanner.CameraAccessDenied){
        return "Помилка доступу до камери";
      } else {
        return "Помилка $e";
      }
    } on FormatException {
      return "null";
    } catch (e){
      return "$e";
    }
  }

  int _getID(String input) {
    List<String> _list = input.split(":");
    try {
      switch(_list.length){
        case 2:
          return int.parse(_list.first);
        case 4:
          return int.parse(_list.last);
        default:
          return 0;
      }
    } catch (e){
      return 0;
    }
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
        Future<List<Documents>> _listDocuments = ImplDocumentsDAO().search(query);
        return _PageOrdersState()._documents(_listDocuments);
        break;
      case 1:
        Future<List<Goods>> _listAddedGoods = UserGoodsDAO().search(query);
        return _PageOrdersState()._goods(_listAddedGoods, true);
        break;
      case 2:
        Future<List<SupplyDocuments>> _listDocuments = ImplSupplyDocumentsDAO().search(query);
        return _PageOrdersState()._supplyDocuments(_listDocuments);
        break;
      case 3:
        Future<List<Goods>> _listGoods = GoodsDAO().search(query);
        return _PageOrdersState()._goods(_listGoods, false);
        break;
      case 4:
        Future<List<Partners>> _listPartners = PartnersDAO().search(query);
        return _PageOrdersState()._partners(_listPartners);
        break;
      default:
        Future<List<Documents>> _listDocuments = ImplDocumentsDAO().search(query);
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

enum _ToUpdate{
  documents, goods, supplyDocuments, defaultUpdate,
}
