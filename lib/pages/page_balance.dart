
import 'dart:async';

import 'package:enterprise/database/impl/pay_office_dao.dart';
import 'package:enterprise/database/pay_desk_dao.dart';
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/models/models.dart';
import 'package:enterprise/models/pay_office.dart';
import 'package:enterprise/models/profile.dart';
import 'package:enterprise/widgets/custom_expansion_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
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

  Future<List<PayOffice>> _futureListPayOffice;
  List<PayOffice> _listPayOfficeToShow;

  Map<String, double> _mapToShow;

  ScrollController _scrollController;
  ScrollController _dialogScrollController;

  int _currencyCode;
  bool _isSwitched;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _scrollController = ScrollController();
    _dialogScrollController = ScrollController();
    _isSwitched = true;
    _futureListPayOffice = ImplPayOfficeDAO().getUnDeleted();
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
                onPressed: (){
                  _sortDialog(_listPayOfficeToShow);
                },
              ),
            ],
          ),
          body: FutureBuilder(
              future: _futureListPayOffice,
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
                    _listPayOfficeToShow = snapshot.data;
                    _listPayOfficeToShow = _listPayOfficeToShow.reversed.toList();
                    _mapToShow = _setMapMap(_listPayOfficeToShow);
                    var _emptyLength = _mapToShow.values.where((element) => element!=0).toList();
                    if(_emptyLength.length==0){
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
        pay.amount = 2000; /// Add amount to payOffice, just for testing, delete in release!
        toReturn.update(pay.currencyName, (value) =>  value + pay.amount);
      }
    });
//    return LinkedHashMap.fromEntries(toReturn.entries.toList().reversed);
    return toReturn;
  }

  void _sortDialog(List<PayOffice> inputCostItem){
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _dialogScrollController
          .jumpTo(_dialogScrollController.position.maxScrollExtent);
    });
    showDialog(
        context: context,
        builder: (context) {
          return OrientationBuilder(
              builder: (context, orientation) {
                return StatefulBuilder(
                  builder: (BuildContext context, void Function(void Function()) setState) {
                    return AlertDialog(
                      contentPadding: EdgeInsets.all(0.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                      ),
                      content: Container(
                        height: inputCostItem.length == 0 ? 50 : inputCostItem.length == 1 ? 115 : inputCostItem.length >3 ? 210 : 160,
                        width: 500,
                        child: ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          controller: _dialogScrollController,
                          itemCount: inputCostItem.length+1,
                          itemBuilder: (BuildContext context, int index){
                            if(inputCostItem.length==0){
                              return Container(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Center(
                                  child: Text("Нема активних гаманців",textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.lightGreen),),
                                ),
                              );
                            }
                            if(inputCostItem.length==index){
                              return Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        height: 60,
                                        padding: EdgeInsets.only(left: 25),
                                        alignment: Alignment.center,
                                        child: Text("Обрати всi",textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.lightGreen),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 25),
                                        child: Switch(
                                          value: _isSwitched,
                                          onChanged: (value) {
                                            setState(() {
                                              _isSwitched = value;
                                              inputCostItem.where((element) => element.isShow = value).toList();
                                              this.setState(() {});
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      height: 1.5,
                                      color: Colors.lightGreen,
                                    ),
                                  ),
                                ],
                              );
                            }
                            if(!inputCostItem[index].isVisible){
                              return Container();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: orientation == Orientation.portrait ? 180 : 350,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(left: 30),
                                      child: Column(
                                        children: <Widget>[
                                          Text(inputCostItem[index].name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 35,
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        children: <Widget>[
                                          Text("${inputCostItem[index].currencyName}",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(right: 25),
                                      child: Column(
                                        children: <Widget>[
                                          Switch(
                                            value: inputCostItem[index].isShow,
                                            onChanged: (value) {
                                              setState(() {
                                                if(_isSwitched){
                                                  _isSwitched = false;
                                                }
                                                _listPayOfficeToShow[index].isShow = !_listPayOfficeToShow[index].isShow;
                                                if(inputCostItem.where((element) => element.isShow).length==inputCostItem.length){
                                                  _isSwitched = true;
                                                }
                                                this.setState(() { });
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );},
                );
              }
          );
        }
    );
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
                                  Text("${amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}", style: TextStyle(fontSize: 18), textAlign: TextAlign.end,),
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
                                      name: _listPayOfficeToShow[listIndex].name,
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
                                      child: Text("${amountFormatter.text} ${CURRENCY_SYMBOL[_currencyCode]}", overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.end,),
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
}