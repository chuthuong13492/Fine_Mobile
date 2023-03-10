class SupplierNoteDTO {
  int? supplierId;
  String? content;

  SupplierNoteDTO({this.supplierId, this.content});

  factory SupplierNoteDTO.fromJson(dynamic json) {
    return SupplierNoteDTO(
        supplierId: json["supplier_id"], content: json["content"]);
  }

  Map<String, dynamic> toJson() {
    return {"supplier_id": supplierId, "content": content};
  }
}
