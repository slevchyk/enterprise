import 'dart:io';

class Pay{
  int id;
  int userID;
  double amount;
  String payment;
  int confirming;
  DateTime date;
  List<File> files;

  Pay({this.id,
    this.userID,
    this.amount,
    this.payment,
    this.confirming,
    this.date,
    this.files
  });

  factory Pay.fromMap(Map<String, dynamic> json) => Pay(
    id: json['id'],
    userID: json['user_id'],
    amount: json["amount"],
    payment: json["payment"],
    confirming: json["confirming"],
    date: json['date'] != null
        ? DateTime.parse(json["date"])
        : null,
    files: json['files']
  );

  Map<String, dynamic> toMap() => {
    'id' : id,
    'user_id' : userID,
    'amount' : amount,
    'payment' : payment,
    'confirming' : confirming,
    'date' : date,
    'files' : files
  };


}