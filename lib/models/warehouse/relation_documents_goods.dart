class RelationDocumentsGoods{
  int documentID;
  int goodsID;

  RelationDocumentsGoods({
    this.documentID,
    this.goodsID,
  });

  factory RelationDocumentsGoods.fromMap(Map<String, dynamic> json) => new RelationDocumentsGoods(
    documentID: json["document_id"],
    goodsID: json["goods_id"],
  );

  Map<String, dynamic> toMap() => {
    "document_id" : documentID,
    "goods_id" : goodsID,
  };
}