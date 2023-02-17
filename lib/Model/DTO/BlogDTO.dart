import 'dart:convert';

class BlogDTO {
  int? id;
  String? title;
  String? imageUrl;
  String? content;
  bool? isDialog;
  Map<String, dynamic>? metaData;

  BlogDTO(
      {this.id,
      this.title,
      this.imageUrl,
      this.content,
      this.isDialog,
      this.metaData});

  factory BlogDTO.fromJson(dynamic data) {
    var value = data['meta_data'];
    if (value != null) {
      value = jsonDecode(value);
    }
    return BlogDTO(
        id: data['id'],
        imageUrl: data['image_url'],
        content: data['blog_content'],
        title: data['title'],
        isDialog: data['is_dialog'],
        metaData: value);
  }
}
