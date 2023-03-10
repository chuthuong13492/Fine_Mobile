class BlogDTO {
  int? id;
  int? storeId;
  String? title;
  String? blogContent;
  String? imageUrl;
  bool? active;
  bool? isDialog;
  String? metadata;
  String? createAt;
  String? updateAt;

  BlogDTO(
      {this.id,
      this.storeId,
      this.title,
      this.blogContent,
      this.imageUrl,
      this.active,
      this.isDialog,
      this.metadata,
      this.createAt,
      this.updateAt});

  BlogDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    storeId = json["storeId"];
    title = json["title"];
    blogContent = json["blogContent"];
    imageUrl = json["imageUrl"];
    active = json["active"];
    isDialog = json["isDialog"];
    metadata = json["metadata"];
    createAt = json["createAt"];
    updateAt = json["updateAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["storeId"] = storeId;
    _data["title"] = title;
    _data["blogContent"] = blogContent;
    _data["imageUrl"] = imageUrl;
    _data["active"] = active;
    _data["isDialog"] = isDialog;
    _data["metadata"] = metadata;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    return _data;
  }
}
