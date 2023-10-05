class TransactionDTO {
  double? amount;
  String? note;
  bool? isIncrease;
  int? type;
  int? status;

  TransactionDTO({
    this.amount,
    this.note,
    this.isIncrease,
    this.type,
    this.status,
  });

  TransactionDTO.fromJson(Map<String, dynamic> json) {
    amount = json["amount"];
    note = json["note"] ?? null;
    isIncrease = json["isActive"];
    type = json["type"];
    status = json["status"];
  }
}
