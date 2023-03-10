abstract class StoreDTO {
  int? id;
  String? name;
  bool? available;

  StoreDTO({this.id, this.name, this.available});

  StoreDTO.fromJson(dynamic json);

  Map<String, dynamic> toJson();
}
