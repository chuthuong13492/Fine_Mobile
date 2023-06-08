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
  List<CartItem>? orderDetails;
  // int? payment;
  int? orderType;
  // int? customerId;
  String? deliveryPhone;
  int? roomId;
  int? timeSlotId;
  // List<SupplierNoteDTO>? notes;
  String? note;
  // User info

  // _vouchers
  // List<VoucherDTO> vouchers;

  Cart.get({
    // this.customerId,
    this.deliveryPhone,
    this.orderType,
    this.timeSlotId,
    this.roomId,
    this.note,
    this.orderDetails,
  });

  Cart({
    // this.customerId,
    this.deliveryPhone,
    this.timeSlotId,
  }) {
    orderDetails = [];
    // vouchers = [];
  }

  // List<VoucherDTO> get vouchers {
  //   if (_vouchers == null) {
  //     _vouchers = [];
  //   }
  //   return _vouchers;
  // }

  factory Cart.fromJson(dynamic json) {
    List<CartItem> list = [];
    if (json["orderDetails"] != null) {
      var itemJson = json["orderDetails"] as List;
      list = itemJson.map((e) => CartItem.fromJson(e)).toList();
    }
    return Cart.get(
      // customerId: json['customerID'],
      deliveryPhone: json['deliveryPhone'] as String,
      orderType: 2,
      timeSlotId: json['timeSlotId'],
      roomId: 2,
      // notes: (json['supplier_notes'] as List)
      //     .map((e) => SupplierNoteDTO.fromJson(e))
      //     .toList(),
      note: json["note"] ?? '',
      orderDetails: list,
      // vouchers: (json['vouchers'] as List)
      //     ?.map((e) => VoucherDTO.fromJson(e))
      //     ?.toList()
    );
  }

  void addProperties(String phone, int timeSlot) {
    // if (customerId == null) {
    //   customerId = Id;
    deliveryPhone = phone;
    timeSlotId = timeSlot;
    // }
  }

  // void addVoucher(VoucherDTO voucher) {
  //   if (vouchers != null) {
  //     vouchers?.clear();
  //     vouchers?.add(voucher);
  //   } else {
  //     vouchers?.add(voucher);
  //     // print(vouchers);
  //   }
  // }

  // void removeVoucher() {
  //   vouchers?.clear();
  // }

  Map<String, dynamic> toJson() {
    List listCartItem = orderDetails!.map((e) => e.toJson()).toList();
    return {
      // "customerId": customerId,
      "deliveryPhone": deliveryPhone,
      "orderType": orderType,
      "timeSlotId": timeSlotId,
      "roomId": roomId,
      // "supplier_notes":
      //     note != null ? note!.map((e) => e.toJson())?.toList() : [],
      "note": note ?? null,
      // "vouchers": vouchers != null
      //     ? vouchers?.map((voucher) => voucher.toJson())?.toList()
      //     : null,
      "orderDetails": listCartItem,
    };
  }

  Map<String, dynamic> toJsonAPi() {
    List<Map<String, dynamic>> listCartItem = [];
    orderDetails!.forEach((element) {
      listCartItem.add(element.toJson());
    });

    Map<String, dynamic> map = {
      // "customerId": customerId,
      "deliveryPhone": deliveryPhone,
      "orderType": orderType,
      "timeSlotId": timeSlotId,
      "roomId": roomId,
      "note": note ?? null,
      "orderDetails": listCartItem,
      // "supplier_notes":
      //     note != null ? note!.map((e) => e.toJson()).toList() : [],
      // "vouchers": vouchers != null
      //     ? vouchers?.map((voucher) => voucher.voucherCode)?.toList()
      //     : null,
    };
    logger.i("Order: " + map.toString());
    return map;
  }

  bool get isEmpty => orderDetails != null && orderDetails!.isEmpty;
  int itemQuantity() {
    int quantity = 0;
    for (CartItem item in orderDetails!) {
      quantity += item.quantity;
    }
    return quantity;
  }

  void addItem(CartItem item) {
    for (CartItem cart in orderDetails!) {
      if (cart.findCartItem(item)) {
        cart.quantity += item.quantity;

        return;
      }
    }
    orderDetails!.add(item);
  }

  void removeItem(CartItem item) {
    print("Quantity: ${item.quantity}");
    orderDetails!.removeWhere((element) =>
        element.findCartItem(item) && element.quantity == item.quantity);
  }

  void updateQuantity(CartItem item) {
    for (CartItem cart in orderDetails!) {
      if (cart.findCartItem(item)) {
        print("Found item");
        cart.quantity = item.quantity;
      }
    }
  }
}

class CartItem {
  int? productInMenuId;
  int? comboId;
  int quantity;
  String? note;

  CartItem(this.productInMenuId, this.comboId, this.quantity, this.note);

  bool findCartItem(CartItem item) {
    bool found = true;

    if (this.productInMenuId != item.productInMenuId) {
      return false;
    }
    if (this.comboId != item.comboId) {
      return false;
    }
    return found;
  }

  // CartItem.fromJson(Map<String, dynamic> json) {
  //   return CartItem(productInMenuId, comboId, quantity, note);
  //   // productInMenuId = json["productInMenuId"];
  //   // comboId = json["comboId"];
  //   // quantity = json["quantity"] as int;
  //   // note = json["note"];
  // }
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      json['productInMenuId'] as int,
      json['comboId'] as int,
      json['quantity'] as int,
      json['String'] as String,
    );
  }

  static List<CartItem> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => CartItem.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["productInMenuId"] = productInMenuId;
    _data["comboId"] = comboId;
    _data["quantity"] = quantity;
    _data["note"] = note ?? "";
    return _data;
  }
}
// class CartItem {
//   ProductDTO? master;
//   List<ProductDTO>? products;
//   String? description;
//   int quantity;

//   CartItem(this.master, this.products, this.description, this.quantity);

  // bool findCartItem(CartItem item) {
  //   bool found = true;

  //   if (this.master!.id != item.master!.id
  //       //  ||
  //       //     this.master.type != item.master.type
  //       ) {
  //     return false;
  //   }

  //   if (this.products!.length != item.products!.length) {
  //     return false;
  //   }
  //   for (int i = 0; i < this.products!.length; i++) {
  //     if (item.products![i].id != this.products![i].id) found = false;
  //   }
  //   if (item.description != this.description) {
  //     found = false;
  //   }
  //   return found;
  // }

//   factory CartItem.fromJson(dynamic json) {
//     List<ProductDTO> list = [];
//     if (json["products"] != null) {
//       var itemJson = json["products"] as List;
//       list = itemJson.map((e) => ProductDTO.fromJson(e)).toList();
//     }
//     return CartItem(
//       ProductDTO.fromJson(json['master']),
//       list,
//       json['description'] as String,
//       json['quantity'] as int,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     List listProducts = products!.map((e) => e.toJson()).toList();
//     return {
//       "master": master!.toJson(),
//       "products": listProducts,
//       "description": description,
//       "quantity": quantity
//     };
//   }

//   // TODO: Xem lai quantity cua tung CartItem
//   Map<String, dynamic> toJsonApi() {
//     // List<Map<String, dynamic>> map = new List();
//     // List productChilds = products!
//     //     .map((productChild) => {
//     //           "product_id": productChild.id,
//     //           "product_in_menu_id": productChild.productInMenuId,
//     //           "quantity": quantity, // TODO: Kiem tra lon hon max va < min
//     //         })
//     //     .toList();

//     return {
//       // "master_product": master.productInMenuId,
//       // "product_childs": productChilds,
//       "description": description,
//       "quantity": quantity
//     };

//     // if (master.type != ProductType.MASTER_PRODUCT) {
//     //   map.add({
//     //     "product_id": master.id,
//     //     "quantity": quantity,
//     //     "parent_id": master.catergoryId
//     //   });
//     // }

//     // products.forEach((element) {
//     //   map.add({
//     //     "product_id": element.id,
//     //     "quantity": quantity,
//     //     "parent_id": element.catergoryId
//     //   });
//     // });
//     // return map;
//   }
// }
