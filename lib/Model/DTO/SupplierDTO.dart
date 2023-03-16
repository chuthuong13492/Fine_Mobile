class SupplierDTO {
  int? id;
  int? destinationId;
  String? storeName;
  String? imageUrl;
  String? contactPerson;
  bool? active;
  DateTime? createdAt;
  DateTime? updatedAt;

  SupplierDTO(
      {this.id,
      this.destinationId,
      this.storeName,
      this.imageUrl,
      this.contactPerson,
      this.active,
      this.createdAt,
      this.updatedAt});

  SupplierDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    destinationId = json["destinationId"];
    storeName = json["storeName"];
    imageUrl = json["imageUrl"];
    contactPerson = json["contactPerson"];
    active = json["active"];
    createdAt = json['createAt'] as String != null
        ? DateTime.parse(json['createAt'] as String)
        : null;
    updatedAt = json['updateAt'] as String != null
        ? DateTime.parse(json['updateAt'] as String)
        : null;
  }

  static List<SupplierDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => SupplierDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["destinationId"] = destinationId;
    _data["storeName"] = storeName;
    _data["imageUrl"] = imageUrl;
    _data["contactPerson"] = contactPerson;
    _data["active"] = active;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    return _data;
  }
}
