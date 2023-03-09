const defaultImg =
    "https://firebasestorage.googleapis.com/v0/b/unidelivery-fad6f.appspot.com/o/images%2Ficons8-rice-bowl-48.png?alt=media&token=5a66159a-0bc1-4527-857d-7fc2801026f4";

class CategoryDTO {
  int? id;
  String? categoryCode;
  String? categoryName;
  String? imageUrl;
  bool? showOnHome;
  String? createAt;
  String? updateAt;

  CategoryDTO(
      {this.id,
      this.categoryCode,
      this.categoryName,
      this.imageUrl,
      this.showOnHome,
      this.createAt,
      this.updateAt});

  CategoryDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    categoryCode = json["categoryCode"];
    categoryName = json["categoryName"];
    imageUrl = json["imageUrl"];
    showOnHome = json["showOnHome"];
    createAt = json["createAt"];
    updateAt = json["updateAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["categoryCode"] = categoryCode;
    _data["categoryName"] = categoryName;
    _data["imageUrl"] = imageUrl;
    _data["showOnHome"] = showOnHome;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    return _data;
  }
}
