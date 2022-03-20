import 'package:enterprise/models/pay_office.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SortWidget{

  static Future sortPayOffice(List<PayOffice> inputCostItem, ScrollController inputScrollController, Function callback, BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      inputScrollController
          .jumpTo(inputScrollController.position.maxScrollExtent);
    });
    bool _isSwitched = inputCostItem.where((element) => element.isShow).length==inputCostItem.length;
    return showDialog(
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
                        // height: inputCostItem.length == 0 ? 50 : inputCostItem.length == 1 ? 15 : inputCostItem.length >3 ? 110 : 160,
                        width: 500,
                        child: ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          controller: inputScrollController,
                          itemCount: inputCostItem.length+1,
                          itemBuilder: (BuildContext context, int index){
                            if(inputCostItem.length==0){
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
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
                                              inputCostItem.forEach((element) {
                                                if(element.isVisible){
                                                  element.isShow = value;
                                                }
                                              });
                                              callback();
                                              return inputCostItem;
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
                                                inputCostItem[index].isShow = value;
                                                if(inputCostItem.where((element) => element.isShow).length==inputCostItem.length){
                                                  _isSwitched = value;
                                                } else if(_isSwitched){
                                                  _isSwitched = false;
                                                }
                                                callback();
                                                return inputCostItem;
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

}