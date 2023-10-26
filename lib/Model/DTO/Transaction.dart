class TransactionDTO {
  double? amount;
  String? note;
  bool? isIncrease;
  int? type;
  int? status;
  DateTime? createdAt;

  TransactionDTO({
    this.amount,
    this.note,
    this.isIncrease,
    this.type,
    this.status,
    this.createdAt,
  });

  TransactionDTO.fromJson(Map<String, dynamic> json) {
    amount = json["amount"];
    note = json["notes"];
    isIncrease = json["isIncrease"];
    type = json["type"];
    status = json["status"];
    createdAt = json['createdAt'] as String != null
        ? DateTime.parse(json['createdAt'] as String)
        : null;
  }
}
