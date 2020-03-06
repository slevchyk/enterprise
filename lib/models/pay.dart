
class Pay{
  int id;
  int userID;
  int paymentStatus;
  double amount;
  String payment;
  int confirming;
  DateTime date;
  String files;

  Pay({this.id,
    this.userID,
    this.paymentStatus,
    this.amount,
    this.payment,
    this.confirming,
    this.date,
    this.files
  });

  factory Pay.fromMap(Map<String, dynamic> json) => Pay(
    id: json['id'],
    userID: json['user_id'],
    paymentStatus: json['payment_status'],
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
    'payment_status' : paymentStatus,
    'amount' : amount,
    'payment' : payment,
    'confirming' : confirming,
    'date' : date != null
        ? date.toIso8601String()
        : null,
    'files' : files
  };

}