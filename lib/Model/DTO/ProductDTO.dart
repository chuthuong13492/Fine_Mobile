import 'dart:ffi';

import 'package:flutter/foundation.dart';

// class ProductDTO {
//   int? id;
//   int? productInMenuId;
//   String? name;
//   String? description;
//   int? type;
//   String? imageURL;
//   List<ProductDTO>? listChild;
//   int? catergoryId;
//   int? supplierId;
//   String? supplierName;
//   List<ProductDTO>? extras;
//   // update
//   double? price;
//   bool? hasExtra;
//   Map? attributes;
//   int? defaultQuantity;
//   int? min;
//   int? max;
//   bool? isAnd;
//   int? generalId;
//   double? minPrice;
//   List<int>? collections;
//   int? bean;

//   @override
//   String toString() {
//     return 'ProductDTO{id: $id, name: $name, description: $description, type: $type, imageURL: $imageURL, listChild: $listChild, catergoryId: $catergoryId, supplierId: $supplierId, extras: $extras, prices: $price, hasExtra: $hasExtra, attributes: $attributes, defaultQuantity: $defaultQuantity, min: $min, max: $max, isAnd: $isAnd}';
//   }

//   ProductDTO(this.id,
//       {this.name,
//       this.productInMenuId,
//       this.imageURL,
//       this.description,
//       this.type,
//       this.listChild,
//       this.catergoryId,
//       this.price,
//       this.supplierId,
//       this.supplierName,
//       this.attributes,
//       this.hasExtra,
//       this.defaultQuantity,
//       this.isAnd,
//       this.max,
//       this.min,
//       this.generalId,
//       this.minPrice,
//       this.collections,
//       this.bean}); // balance. point;

//   factory ProductDTO.fromJson(dynamic json) {
//     var type = json['product_type_id'] as int;
//     // List<int> listExtra = jsonExtra.cast<int>().toList();

//     Map attribute = json['attributes'] as Map;
//     if (attribute != null) {
//       for (int i = 0; i < attribute.keys.length; i++) {
//         if (attribute.values.elementAt(i) == null) {
//           attribute.remove(attribute.keys.elementAt(i));
//         }
//       }
//     }

//     ProductDTO product = ProductDTO(json["product_id"],
//         name: json['product_name'] as String,
//         productInMenuId: json['product_in_menu_id'],
//         description: json['description'] as String,
//         type: type,
//         imageURL: json['pic_url'] as String,
//         catergoryId: json['category_id'],
//         supplierId: json['supplier_id'] as int,
//         supplierName: json['supplier_name'],
//         // prices: prices,
//         // extraId: listExtra,
//         hasExtra: json['has_extra'] as bool,
//         attributes: attribute,
//         defaultQuantity: json["default"] ?? 0,
//         min: json["min"] ?? 0,
//         max: json["max"] ?? 0,
//         generalId: json['general_product_id'],
//         bean: json['bean']);

//     if (json['collection_id'] != null) {
//       var listCollection = json['collection_id'] as List;
//       product.collections = listCollection.cast<int>().toList();
//     }
//     product.price = json["price"];

//     // switch (type) {
//     //   case ProductType.MASTER_PRODUCT:
//     //     var listChildJson = json['child_products'] as List ?? [];

//     //     List<ProductDTO> listChild =
//     //         listChildJson.map((e) => ProductDTO.fromJson(e)).toList();

//     //     product.listChild = listChild;
//     //     product.minPrice = json['min_price'];
//     //     break;
//     //   case ProductType.COMPLEX_PRODUCT:
//     //     if (product.hasExtra != null && product.hasExtra) {
//     //       var listExtraJson = json['extras'] as List;

//     //       List<ProductDTO> listExtra =
//     //           listExtraJson?.map((e) => ProductDTO.fromJson(e))?.toList();

//     //       product.extras = listExtra;
//     //     }
//     //     break;
//     //   default:
//     //     break;
//     // }

//     return product;
//   }

//   Map<String, dynamic> toJson() {
//     Map<String, dynamic> prodJson = {
//       "product_id": id,
//       "product_in_menu_id": productInMenuId,
//       "product_name": name,
//       // price: double.parse(json['price'].toString()),
//       "description": description,
//       "product_type_id": type,
//       "pic_url": imageURL,
//       "catergory_id": catergoryId,
//       "child_products": listChild,
//       "supplier_id": supplierId,
//       "supplier_name": supplierName,
//       "hasExtra": hasExtra,
//       "attributes": attributes,
//       "default": defaultQuantity,
//       "min": min,
//       "max": max,
//       "extras": extras,
//       "general_product_id": generalId,
//       "min_price": minPrice,
//       "collection_id": collections,
//       "price": price,
//       "bean": bean
//     };

//     return prodJson;
//   }

//   static List<ProductDTO> fromList(dynamic jsonList) {
//     var list = jsonList as List;
//     return list.map((map) => ProductDTO.fromJson(map)).toList();
//   }

//   ProductDTO getChildByAttributes(Map attributes) {
//     return listChild!
//         .firstWhere((child) => mapEquals(child.attributes, attributes));
//   }
// }

class ProductDTO {
  String? id;
  String? productCode;
  String? productName;
  String? categoryId;
  String? storeId;
  int? productType;
  String? imageUrl;
  bool? isActive;
  bool? isStackable;
  DateTime? createAt;
  DateTime? updateAt;
  List<ProductAttributes>? attributes;

  ProductDTO({
    this.id,
    this.productName,
    this.productCode,
    this.categoryId,
    this.storeId,
    this.productType,
    this.imageUrl,
    this.isActive,
    this.isStackable,
    this.createAt,
    this.updateAt,
    List<ProductAttributes>? attributes,
  }) : attributes = attributes?.map((attr) {
          return ProductAttributes(
            id: attr.id,
            productId: attr.productId,
            name: attr.name,
            code: attr.code,
            size: attr.size,
            rotationType: attr.rotationType,
            height: attr.height,
            width: attr.width,
            length: attr.length,
            price: attr.price,
            isActive: attr.isActive,
            isStackable: isStackable,
            createAt: attr.createAt,
            updateAt: attr.updateAt,
          );
        }).toList();

  factory ProductDTO.fromJson(Map<String, dynamic> json) {
    return ProductDTO(
      id: json["id"] as String,
      productName: json["productName"],
      productCode: json["code"],
      categoryId: json["categoryId"],
      storeId: json["storeId"],
      productType: json["productType"],
      imageUrl: json["imageUrl"],
      isActive: json["isActive"],
      isStackable: json["isStackable"],
      createAt: json['createAt'] as String != null
          ? DateTime.parse(json['createAt'] as String)
          : null,
      updateAt: json['updateAt'] as String != null
          ? DateTime.parse(json['updateAt'] as String)
          : null,
      attributes: json["productAttributes"] == null
          ? null
          : (json["productAttributes"] as List)
              .map((e) => ProductAttributes.fromJson(e))
              .toList(),
    );
    // id = json["id"] as String;
    // productName = json["productName"];
    // productCode = json["code"];
    // categoryId = json["categoryId"];
    // storeId = json["storeId"];
    // productType = json["productType"];
    // imageUrl = json["imageUrl"];
    // isActive = json["isActive"];
    // isStackable = json["isStackable"];
    // createAt = json['createAt'] as String != null
    //     ? DateTime.parse(json['createAt'] as String)
    //     : null;
    // updateAt = json['updateAt'] as String != null
    //     ? DateTime.parse(json['updateAt'] as String)
    //     : null;
    // attributes = json["productAttributes"] == null
    //     ? null
    //     : (json["productAttributes"] as List)
    //         .map((e) => ProductAttributes.fromJson(e))
    //         .toList();
  }

  static List<ProductDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => ProductDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["productName"] = productName;
    _data["productCode"] = productCode;
    // _data["generalProductId"] = generalProductId;

    _data["categoryId"] = categoryId;
    // _data["categoryName"] = categoryName;
    _data["storeId"] = storeId;
    _data["productType"] = productType;
    // _data["storeName"] = storeName;
    _data["imageUrl"] = imageUrl;
    _data["isActive"] = isActive;
    // _data["isAvailable"] = isAvailable;
    // _data["status"] = status;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    if (attributes != null) {
      _data["products"] = attributes?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class ProductAttributes {
  String? id;
  String? productId;
  String? name;
  String? code;
  String? size;
  int? rotationType;
  double? height;
  double? width;
  double? length;
  double? price;
  bool? isActive;
  bool? isStackable;
  DateTime? createAt;
  DateTime? updateAt;

  ProductAttributes({
    this.id,
    this.productId,
    this.name,
    this.code,
    this.size,
    this.rotationType,
    this.height,
    this.width,
    this.length,
    this.price,
    this.isActive,
    this.isStackable,
    this.createAt,
    this.updateAt,
  });

  ProductAttributes.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    productId = json["productId"] as String;
    name = json["name"];
    code = json["code"];
    size = json["size"] ?? null;
    rotationType = json["rotationType"];
    height = json["height"];
    width = json["width"];
    length = json["length"];
    price = json["price"];
    isActive = json["isActive"];
    createAt = json['createAt'] as String != null
        ? DateTime.parse(json['createAt'] as String)
        : null;
    updateAt = json['updateAt'] as String != null
        ? DateTime.parse(json['updateAt'] as String)
        : null;
  }

  static List<ProductAttributes> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => ProductAttributes.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["productId"] = productId;
    _data["name"] = name;
    _data["code"] = code;
    _data["size"] = size;
    _data["price"] = price;
    _data["isActive"] = isActive;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    return _data;
  }
}

class AddProductToCartResponse {
  StatusProductInCart? status;
  ProductInCart? product;
  List<ProductInCart>? card;
  List<ProductInCart>? productsRecommend;

  AddProductToCartResponse({
    this.status,
    this.product,
    this.card,
    this.productsRecommend,
  });

  AddProductToCartResponse.fromJson(Map<String, dynamic> json) {
    status = json["status"] == null
        ? null
        : StatusProductInCart.fromJson(json["status"]);
    product = json["product"] == null
        ? null
        : ProductInCart.fromJson(json["product"]);
    card = json["card"] == null
        ? null
        : (json["card"] as List).map((e) => ProductInCart.fromJson(e)).toList();
    productsRecommend = json["productsRecommend"] == null
        ? null
        : (json["productsRecommend"] as List)
            .map((e) => ProductInCart.fromJson(e))
            .toList();
  }

  static List<AddProductToCartResponse> fromList(
      List<Map<String, dynamic>> list) {
    return list.map((map) => AddProductToCartResponse.fromJson(map)).toList();
  }
}

class ProductInCart {
  // StatusProductInCart? status;
  String? id;
  String? name;
  String? code;
  String? size;
  String? imageUrl;
  double? price;
  int? quantity;

  ProductInCart({
    // this.status,
    this.id,
    this.name,
    this.code,
    this.size,
    this.imageUrl,
    this.price,
    this.quantity,
  });

  ProductInCart.fromJson(Map<String, dynamic> json) {
    // status = json["status"] == null
    //     ? null
    //     : StatusProductInCart.fromJson(json["status"]);
    id = json["id"] as String;
    name = json["name"];
    code = json["code"];
    size = json["size"] ?? null;
    imageUrl = json["imageUrl"] ?? null;
    price = json["price"];
    quantity = json["quantity"];
  }

  static List<ProductInCart> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => ProductInCart.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["code"] = code;
    _data["size"] = size;
    _data["imageUrl"] = imageUrl;
    _data["price"] = price;
    _data["quantity"] = quantity;
    return _data;
  }
}

class StatusProductInCart {
  bool? success;
  String? message;
  String? errorCode;

  StatusProductInCart({
    this.success,
    this.message,
    this.errorCode,
  });

  StatusProductInCart.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    message = json["message"];
    errorCode = json["errorCode"].toString();
  }

  static List<StatusProductInCart> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => StatusProductInCart.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["success"] = success;
    _data["message"] = message;
    _data["errorCode"] = errorCode;
    return _data;
  }
}
