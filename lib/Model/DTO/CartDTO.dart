import 'dart:ffi';

import 'package:fine/Model/DTO/SupplierNoteDTO.dart';
import 'package:logger/logger.dart';

import 'index.dart';

final logger = Logger(
    printer: PrettyPrinter(
  methodCount: 0,
  errorMethodCount: 5,
  lineLength: 50,
  colors: true,
  printEmojis: true,
  printTime: false,
));

class Cart {
  String? timeSlotId;
  int? quantity;
  bool? isNextDay;
  List<CartItem>? items;

  Cart.get({
    this.timeSlotId,
    this.quantity,
    this.isNextDay,
    this.items,
  });

  Cart({
    this.timeSlotId,
    this.quantity,
    this.isNextDay,
  }) {
    items = [];
  }

  factory Cart.fromJson(dynamic json) {
    List<CartItem> list = [];
    if (json["orderDetails"] != null) {
      var itemJson = json["orderDetails"] as List;
      list = itemJson.map((e) => CartItem.fromJson(e)).toList();
    }
    return Cart.get(
      quantity: json["quantity"],
      timeSlotId: json['timeSlotId'],
      isNextDay: json['isNextDay'],
      items: list,
    );
  }

  Map<String, dynamic> toJson() {
    List listCartItem = items!.map((e) => e.toJson()).toList();
    return {
      "quantity": quantity,
      "timeSlotId": timeSlotId,
      "isNextDay": isNextDay,
      "orderDetails": listCartItem,
    };
  }

  bool get isEmpty => items != null && items!.isEmpty;
  int itemQuantity() {
    int quantity = 0;
    for (CartItem item in items!) {
      quantity += item.quantity;
    }
    return quantity;
  }

  void addItem(CartItem item) {
    for (CartItem cart in items!) {
      if (cart.findCartItem(item)) {
        cart.quantity += item.quantity;

        return;
      }
    }
    items!.add(item);
  }

  void insertItem(CartItem item) {
    for (CartItem cart in items!) {
      if (cart.findCartItem(item)) {
        cart.quantity += item.quantity;

        return;
      }
    }
    items!.insert(0, item);
  }

  void removeItem(CartItem item) {
    print("Quantity: ${item.quantity}");
    items!.removeWhere((element) => element.findCartItem(item));
  }

  void updateQuantity(CartItem item) {
    for (CartItem cart in items!) {
      if (cart.findCartItem(item)) {
        print("Found item");
        cart.fixTotal = item.fixTotal;
        cart.quantity = item.quantity;
        cart.isChecked = item.isChecked;
      }
    }
  }

  void updateIsAdded(CartItem item, bool isAdd) {
    for (CartItem cart in items!) {
      if (cart.findCartItem(item)) {
        cart.isAddParty = isAdd;
        if (isAdd == false) {
          cart.isChecked = false;
        }
      }
    }
  }

  void updateCheck(CartItem item, bool check) {
    for (CartItem cart in items!) {
      if (cart.findCartItem(item)) {
        print("Check item");
        cart.isChecked = check;
      }
    }
  }
}

class CartItem {
  String? productId;
  String? productName;
  String? imgUrl;
  String? size;
  int? rotationType;
  double? height;
  double? width;
  double? length;
  double? price;
  double? fixTotal;
  int quantity;
  bool? isStackable;
  bool? isChecked;
  bool? isAddParty;

  CartItem(
    this.productId,
    this.productName,
    this.imgUrl,
    this.size,
    this.rotationType,
    this.height,
    this.width,
    this.length,
    this.price,
    this.fixTotal,
    this.quantity,
    this.isStackable,
    this.isChecked,
    this.isAddParty,
  );

  bool findCartItem(CartItem item) {
    bool found = true;

    if (this.productId != item.productId) {
      return false;
    }
    return found;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      json['productId'] as String,
      json["productName"] as String,
      json["imgUrl"] as String,
      json["size"] as String,
      json["rotationType"] as int,
      json["height"] as double,
      json["width"] as double,
      json["length"] as double,
      json["price"] as double,
      json["fixTotal"] as double,
      json['quantity'] as int,
      json['isStackable'] as bool,
      json['isChecked'] as bool,
      json['isAddParty'] as bool,
    );
  }

  static List<CartItem> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => CartItem.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = productId;
    _data["productId"] = productId;
    _data["productName"] = productName;
    _data["imgUrl"] = imgUrl;
    _data["size"] = size;
    _data["rotationType"] = rotationType;
    _data["height"] = height;
    _data["width"] = width;
    _data["length"] = length;
    _data["price"] = price;
    _data["fixTotal"] = fixTotal;
    _data["quantity"] = quantity;
    _data["isStackable"] = isStackable;
    _data["isChecked"] = isChecked;
    _data["isAddParty"] = isAddParty;

    return _data;
  }
}
