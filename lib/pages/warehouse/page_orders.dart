import 'package:enterprise/database/warehouse/documents_dao.dart';
import 'package:enterprise/database/warehouse/goodsAdded_dao.dart';
import 'package:enterprise/database/warehouse/goods_dao.dart';
import 'package:enterprise/database/warehouse/partners_dao.dart';
import 'package:enterprise/models/warehouse/documnets.dart';
import 'package:enterprise/models/warehouse/goods.dart';
import 'package:enterprise/models/warehouse/partners.dart';
import 'file:///D:/Programs/Flutter/enterprise/lib/pages/warehouse/page_documents_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

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

  bool _isVisible;

  final List<Tab> _myTabs = <Tab>[
    Tab(text: 'Список замовлень'),
    Tab(text: 'Список номенклатур'),
    Tab(text: 'Номенклатура постачальника'),
    Tab(text: 'Партнери',),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _isVisible = true;
    _tabController = TabController(vsync: this, length: _myTabs.length);

    _tabController.addListener(() {
      if(_tabController.index >= 2){
        if(_isVisible == true) {
          setState((){
            _isVisible = false;
          });
        }
      } else {
        if(_tabController.index <= 1){
          if(_isVisible == false) {
            setState((){
              _isVisible = true;
            });
          }
        }
      }
    });

    _documentsList = DocumentsDAO().getAll();
    _goodsList = GoodsDAO().getAll();
    _goodsAddedList = GoodsAddedDAO().getAll();
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
          appBar: AppBar(
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
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
                tabs: _myTabs
            ),
          ),
          body: TabBarView(
              controller: _tabController,
              children: [
                _documents(_documentsList),
                _goods(_goodsAddedList, true),
                _goods(_goodsList, false),
                _partners(_partnersList),
              ]
          ),
          floatingActionButton: Visibility(
            visible: _isVisible,
              child: FloatingActionButton(
                onPressed: () {
                  switch(_tabController.index) {
                    case 0:
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return DocumentsView(
                          currentDocuments: null,
                          enableEdit: true,
                          partnersList: _partnersList,
                        );
                      })).whenComplete(() => _load("documents"));
                      break;
                    case 1:
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return GoodsView(
                          currentGoods: null,
                          enableEdit: true,
                          isNew: false,
                          goodsList: _goodsList,
                        );
                      })).whenComplete(() => _load("goodsAdded"));
                      break;
                    default:
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return DocumentsView(
                          currentDocuments: null,
                          enableEdit: true,
                          partnersList: _partnersList,
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

  Widget _documents(Future<List<Documents>> documentsList){
    return FutureBuilder(
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
            var _documentsList = snapshot.data;
            return Center(
              child: ListView.builder(
                itemCount: _documentsList == null
                    ? 0
                    : _documentsList.length,
                itemBuilder: (BuildContext context, int index) {
                  Documents _documents = _documentsList[index];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return DocumentsView(
                          currentDocuments: _documents,
                          enableEdit: false,
                          partnersList: _partnersList,
                        );
                      })).whenComplete(() => _load("documents"));
                    },
                    child: Hero(
                        tag: 'document_${_documents.mobID}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            isThreeLine: true,
                            leading: CircleAvatar(
                              child: Text('${_documents.mobID}'),
                            ),
                            title: Text('Партнер: ${_documents.partner}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Дата: ${DateFormat('dd.MM.yyyy')
                                    .format(_documents.date)}'),
                                Text('Номер: ${_documents.number}'),
                              ],
                            ),
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
    return FutureBuilder(
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
                itemCount: _goodsList == null
                    ? 0
                    : _goodsList.length,
                itemBuilder: (BuildContext context, int index) {
                  Goods _goods = _goodsList[index];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_){
                        return GoodsView(
                          currentGoods: _goods,
                          enableEdit: false,
                          isNew: !isNew,
                          goodsList: this._goodsList,
                        );
                      })).whenComplete(() => _load("goodsAdded"));
                    },
                    child: Hero(
                        tag: 'good_${_goods.mobID}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            isThreeLine: true,
                            leading: CircleAvatar(
                              child: Text('${_goods.mobID}'),
                            ),
                            title: Text(_goods.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Кількість: ${_goods.count}'),
                                Text('Одиницi вимiру: ${_goods.unit}'),
                                Text('Статус: ${_goods.status
                                    ? 'Робочий'
                                    : 'Чорновик'}'),
                              ],
                            ),
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

  Widget _partners(Future<List<Partners>> partnersList){
    return FutureBuilder(
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
            var _partnersList = snapshot.data;
            return Center(
              child: ListView.builder(
                itemCount: _partnersList == null
                    ? 0
                    : _partnersList.length,
                itemBuilder: (BuildContext context, int index) {
                  Partners _partners = _partnersList[index];
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
        case "document":
          _documentsList = DocumentsDAO().getAll();
          _goodsList = GoodsDAO().getAll();
          _partnersList = PartnersDAO().getAll();
          break;
        case "goodsAdded":
          _goodsAddedList = GoodsAddedDAO().getAll();
          _goodsList = GoodsDAO().getAll();
          _partnersList = PartnersDAO().getAll();
          break;
        default:
          _documentsList = DocumentsDAO().getAll();
          _goodsList = GoodsDAO().getAll();
          _goodsAddedList = GoodsAddedDAO().getAll();
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
        Future<List<Goods>> _listAddedGoods = GoodsAddedDAO().search(query);
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
