
import 'package:enterprise/models/constants.dart';
import 'package:enterprise/widgets/custom_expansion_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PageBalance extends StatefulWidget{
  @override
  _PageBalanceState createState() => _PageBalanceState();
}

class _PageBalanceState extends State<PageBalance>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final amountFormatter =
  MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: ' ');
  List<Test> listTest = [];
  List<Test> _listToShow = [];
  Map<int, double> _mapToShow;

  ScrollController _scrollController;
  ScrollController _dialogScrollController;

  bool _isSwitched;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _dialogScrollController = ScrollController();
    _isSwitched = true;

    for(int i = 1; i <= 20; i++){
      if(i%2==0){
        listTest.add(Test(name: "Гаманець $i", amount: double.parse((2000+i).toString()),isUsed: false, isViewed: true, currency: "UAH", code: 980 ));
      } else {
        listTest.add(Test(name: "Гаманець $i", amount: double.parse((2000+i).toString()),isUsed: true, isViewed: false, currency: "UAH", code: 980));
      }
    }
    listTest.add(Test(name: "Гаманець 21", amount: double.parse((2000+6).toString()),isUsed: false, isViewed: true, currency: "USD", code: 840 ));
    listTest.add(Test(name: "Гаманець 22", amount: double.parse((2000+7).toString()),isUsed: true, isViewed: false, currency: "USD", code: 840 ));
    listTest.add(Test(name: "Гаманець 23", amount: double.parse((2000+8).toString()),isUsed: false, isViewed: true, currency: "EUR", code: 978 ));
    listTest.add(Test(name: "Гаманець 24", amount: double.parse((2000+9).toString()),isUsed: true, isViewed: false, currency: "EUR", code: 978 ));
    listTest = listTest.reversed.toList();
    _listToShow = listTest;

    _mapToShow = _setMapMap(listTest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Баланс"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: (){
              _sortDialog();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white60,
      body: _sceneToShow(_mapToShow),
    );
  }

  _sortDialog(){
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _dialogScrollController
          .jumpTo(_dialogScrollController.position.maxScrollExtent+listTest.length);
    });
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))
                ),
                content: Container(
                  height: listTest.length == 1 ? 115 : listTest.length >3 ? 300 : 160,
                  width: 500,
                  child: ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    controller: _dialogScrollController,
                    itemCount: listTest.length+1,
                    itemBuilder: (BuildContext context, int index){
                      if(listTest.length==index){
                        return Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  height: 60,
                                  padding: EdgeInsets.only(left: 35),
                                  alignment: Alignment.center,
                                  child: Text("Обрати всi",textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.lightGreen),),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 25),
                                  child: Switch(
                                    value: _isSwitched,
                                    onChanged: (value) {
                                      List<Test> list = [];
                                      setState(() {
                                        _isSwitched = value;
                                        list = listTest.where((element) => element.isShow?
                                        element.isShow:
                                        element.isShow=true)
                                            .toList();
                                        _mapToShow = _setMapMap(list);
                                        _listToShow = list;
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Column(
                                  children: <Widget>[
                                    Text(listTest[index].name),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Column(
                                  children: <Widget>[
                                    Switch(
                                      value: listTest[index].isShow,
                                      onChanged: (value) {
                                        setState(() {
                                          if(_isSwitched){
                                            _isSwitched = false;
                                          }
                                          listTest[index].isShow = !listTest[index].isShow;
                                          _mapToShow = _setMapMap(listTest);
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

  Map<int, double> _setMapMap(List<Test> list){
    Map<int, double> toReturn = {
      980 : 0,
      840 : 0,
      978 : 0,
    };
    list.forEach((pay) {
      if(pay.isShow){
        toReturn.update(pay.code, (value) =>  value + pay.amount);
      }
    });
    return toReturn;
  }

  Widget _sceneToShow(Map<int, double> listToShow) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: listToShow.keys.length,
        itemBuilder: (BuildContext context, int index) {
          if(listToShow.values.elementAt(index)==0){
            return Container();
          }
          amountFormatter.text = listToShow.values.elementAt(index).toStringAsFixed(2);
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
                                  Text("Всього, ${CURRENCY_NAME[listToShow.keys.elementAt(index)]}", style: TextStyle(fontSize: 18),),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width/4,
                              child: Wrap(
                                children: <Widget>[
                                  Text("${amountFormatter.text} ${CURRENCY_SYMBOL[listToShow.keys.elementAt(index)]}", style: TextStyle(fontSize: 18),),
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
                          itemCount: _listToShow.length+1,
                          itemBuilder: (BuildContext context, int listIndex) {
                            if(_listToShow.length==listIndex){
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Container(
                                  height: 1.5,
                                  color: Colors.lightGreen,
                                ),
                              );
                            }
                            if(!_listToShow[listIndex].isShow){
                              return Container();
                            }
                            amountFormatter.text = _listToShow[listIndex].amount.toStringAsFixed(2);
                            if(_listToShow[listIndex].code==listToShow.keys.elementAt(index)){
                              return Padding(
                                padding: EdgeInsets.only(left: 17, top: 5, right: 25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(_listToShow[listIndex].name),
                                    Text("${amountFormatter.text} ${CURRENCY_SYMBOL[listToShow.keys.elementAt(index)]}"),
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
///For testing
class Test{
  String name;
  String currency;
  double amount;
  int code;
  bool isShow;
  bool isUsed;
  bool isViewed;

  Test({
    this.name,
    this.currency,
    this.amount,
    this.code,
    this.isShow = true,
    this.isUsed,
    this.isViewed
  });
}