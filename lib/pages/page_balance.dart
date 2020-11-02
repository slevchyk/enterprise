
import 'package:enterprise/database/impl/pay_office_dao.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/models/user_grants.dart';
import 'package:enterprise/widgets/custom_expansion_title.dart';
import 'package:enterprise/widgets/sort_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PageBalance extends StatefulWidget{
  final Profile profile;

  PageBalance({
    this.profile,
  });

  @override
  _PageBalanceState createState() => _PageBalanceState();
}

class _PageBalanceState extends State<PageBalance>{
  Profile _profile;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final amountFormatter =
  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');

  List<PayOffice> _listPayOfficeToShow;

  Map<String, double> _mapToShow;

  ScrollController _scrollController;
  ScrollController _scrollControllerPayOffice;

  int _currencyCode;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _scrollController = ScrollController();
    _scrollControllerPayOffice = ScrollController();
  }

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder (
      builder: (context, orientation) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("Баланс"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.sort),
                onPressed: () {
                  SortWidget.sortPayOffice(_listPayOfficeToShow, _scrollControllerPayOffice, _callBack ,context);
                },
              ),
              IconButton(
                icon: Icon(Icons.sync),
                onPressed: (){
                  _load();
                },
              ),
            ],
          ),
          body: FutureBuilder(
              future: ImplPayOfficeDAO().getUnDeleted(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                switch(snapshot.connectionState) {
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
                    var where;
                    if(_listPayOfficeToShow!=null){
                      where = _listPayOfficeToShow?.where((payOffice) => payOffice.isShow==false);
                    }

                    if(where==null){
                      _listPayOfficeToShow = snapshot.data;
                    }

                    _mapToShow = _setMapMap(_listPayOfficeToShow);
                    int _emptyLength = _mapToShow.values.where((element) => element!=0).toList().length;
                    if(_emptyLength==0){
                      return Container(
                        child: Center(
                          child: Text("Нема інформації по гаманцях",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }
                    return _sceneToShow(_mapToShow, orientation);
                    break;
                  default:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }
              }
          ),
        );
      },
    );
  }

  Map<String, double> _setMapMap(List<PayOffice> list){
    Map<String, double> toReturn = {} ;
    CURRENCY_NAME.values.forEach((element) {
      toReturn.addAll({element : 0});
    });
    list.forEach((pay) {
      if(!pay.isVisible){
        return;
      }
      if(pay.isShow){
        if(pay.amount==null){
          pay.amount = 0;
        }
        toReturn.update(pay.currencyName, (value) =>  value + pay.amount);
      }
    });
    return toReturn;
  }

  Widget _sceneToShow(Map<String, double> listToShow, Orientation orientation) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: listToShow.keys.length,
        itemBuilder: (BuildContext context, int index) {
          if(listToShow.values.elementAt(index)==0){
            return Container();
          }
          amountFormatter.text = listToShow.values.elementAt(index).toStringAsFixed(2);
          _currencyCode = CURRENCY_NAME.keys
              .firstWhere((element) => CURRENCY_NAME[element] == listToShow.keys.elementAt(index),
              orElse: () => null);
          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.lightGreen, width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  CustomExpansionTile(
                    title: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width/3,
                              child: Wrap(
                                children: <Widget>[
                                  Text("Всього, ${listToShow.keys.elementAt(index)}", style: TextStyle(fontSize: 18),),
                                ],
                              ),
                            ),
                            Container(
                              width: orientation == Orientation.landscape ? MediaQuery.of(context).size.height/2.5 : MediaQuery.of(context).size.width/4,
                              child: Wrap(
                                children: <Widget>[
                                  Text("${listToShow.values.elementAt(index).isNegative ? "-" : ""}${amountFormatter.text}${CURRENCY_SYMBOL[_currencyCode]}", style: TextStyle(fontSize: 18), textAlign: TextAlign.end,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: <Widget>[
                      ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _listPayOfficeToShow.length+1,
                          itemBuilder: (BuildContext context, int listIndex) {
                            if(_listPayOfficeToShow.length==listIndex){
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Container(
                                  height: 1.5,
                                  color: Colors.lightGreen,
                                ),
                              );
                            }
                            if(!_listPayOfficeToShow[listIndex].isShow){
                              return Container();
                            }
                            if(!_listPayOfficeToShow[listIndex].isVisible){
                              return Container();
                            }
                            if(_listPayOfficeToShow[listIndex].currencyName==listToShow.keys.elementAt(index)){
                              amountFormatter.text = _listPayOfficeToShow[listIndex].amount.toStringAsFixed(2);
                              _currencyCode = CURRENCY_NAME.keys
                                  .firstWhere((element) => CURRENCY_NAME[element] == listToShow.keys.elementAt(index),
                                  orElse: () => null);
                              return FlatButton(
                                onPressed: () async {
                                  RouteArgs args = RouteArgs(
                                      profile: _profile,
                                      currencyCode: _currencyCode,
                                      payOffice: _listPayOfficeToShow[listIndex],
                                      listDynamic: await PayDeskDAO().getByPayOfficeID(_listPayOfficeToShow[listIndex].accID));
                                  Navigator.pushNamed(context, "/balance/details", arguments: args);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width/2,
                                      child: Text(_listPayOfficeToShow[listIndex].name, overflow: TextOverflow.ellipsis, maxLines: 2,),
                                    ),
                                    Container(
                                      width: orientation == Orientation.landscape ? MediaQuery.of(context).size.height/2.5 : MediaQuery.of(context).size.width/3,
                                      child: Text("${ _listPayOfficeToShow[listIndex].amount.isNegative ? "-" : ""}${amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}", overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.end,),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container();
                          }
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        );
  }

  void _load() async {
    if((await UserGrants.sync(scaffoldKey: _scaffoldKey))){
      setState(() {});
    }
  }

  void _callBack(){
    setState(() {});
  }

}