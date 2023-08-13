import 'index.dart';

class MenuDTO {
  String? id;
  String? timeSlotId;
  String? menuName;
  String? imgUrl;
  int? position;
  bool? isActive;
  DateTime? createAt;
  DateTime? updateAt;
  List<ProductDTO>? products;

  MenuDTO(
      {this.id,
      this.timeSlotId,
      this.menuName,
      this.imgUrl,
      this.position,
      this.isActive,
      this.createAt,
      this.updateAt,
      this.products});

  MenuDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    timeSlotId = json["timeSlotId"] as String;
    menuName = json["menuName"];
    imgUrl = json["imgUrl"];
    position = json["position"];
    isActive = json["isActive"];
    createAt = json['createAt'] as String != null
        ? DateTime.parse(json['createAt'] as String)
        : null;
    updateAt = json['updateAt'] as String != null
        ? DateTime.parse(json['updateAt'] as String)
        : null;
    products = json["products"] == null
        ? null
        : (json["products"] as List)
            .map((e) => ProductDTO.fromJson(e))
            .toList();
  }

  static List<MenuDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => MenuDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["timeSlotId"] = timeSlotId;
    _data["menuName"] = menuName;
    _data["imgUrl"] = imgUrl;
    _data["position"] = position;
    _data["isActive"] = isActive;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    if (products != null) {
      _data["products"] = products?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}
