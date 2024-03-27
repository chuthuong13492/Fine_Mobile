class StationDTO {
  String? id;
  String? name;
  String? code;
  String? areaCode;
  String? floorId;
  bool? isActive;
  DateTime? createAt;
  DateTime? updateAt;

  StationDTO({
    this.id,
    this.name,
    this.code,
    this.areaCode,
    this.floorId,
    this.isActive,
    this.createAt,
    this.updateAt,
  });

  StationDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    code = json["code"];
    areaCode = json["areaCode"];
    floorId = json["floorId"];
    isActive = json["isActive"];
    createAt = json['createAt'] as String != null
        ? DateTime.parse(json['createAt'] as String)
        : null;
    updateAt = json['updateAt'] as String != null
        ? DateTime.parse(json['updateAt'] as String)
        : null;
  }

  static List<StationDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => StationDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["code"] = code;
    _data["areaCode"] = areaCode;
    _data["floorId"] = floorId;
    _data["isActive"] = isActive;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    return _data;
  }
}
