class RelationSupplyDocumentsGoods{
  int documentID;
  int goodsID;

  RelationSupplyDocumentsGoods({
    this.documentID,
    this.goodsID,
  });

  factory RelationSupplyDocumentsGoods.fromMap(Map<String, dynamic> json) => new RelationSupplyDocumentsGoods(
    documentID: json["supply_document_id"],
    goodsID: json["goods_id"],
  );

  Map<String, dynamic> toMap() => {
    "supply_document_id" : documentID,
    "goods_id" : goodsID,
  };
}