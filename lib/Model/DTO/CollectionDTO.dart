import 'package:fine/Model/DTO/ProductDTO.dart';

class CollectionDTO {
  int? id;
  String? name;
  String? description;
  List<ProductDTO>? products;
  bool? isSelected;

  CollectionDTO(
      {this.id,
      this.name,
      this.products = const [],
      this.isSelected,
      this.description});

  factory CollectionDTO.fromJson(dynamic json) {
    return CollectionDTO(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        isSelected: false,
        products: (json['products'] as List ?? [])
            .map((data) => ProductDTO.fromJson(data))
            .toList());
  }

  static List<CollectionDTO> fromList(dynamic jsonList) {
    var list = jsonList as List;
    return list.map((map) => CollectionDTO.fromJson(map)).toList();
  }
}
