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
  List<CartItem>? items;
  int? payment;
  int? timeSlotId;
  List<SupplierNoteDTO>? notes;
  // User info

  // _vouchers
  // List<VoucherDTO> vouchers;

  Cart.get({this.items, this.payment, this.notes, this.timeSlotId});

  Cart() {
    items = [];
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
    if (json["items"] != null) {
      var itemJson = json["items"] as List;
      list = itemJson.map((e) => CartItem.fromJson(e)).toList();
    }
    return Cart.get(
      items: list,
      payment: json['payment'],
      timeSlotId: json['timeslot_id'],
      notes: (json['supplier_notes'] as List)
          ?.map((e) => SupplierNoteDTO.fromJson(e))
          ?.toList(),
      // vouchers: (json['vouchers'] as List)
      //     ?.map((e) => VoucherDTO.fromJson(e))
      //     ?.toList()
    );
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
    List listCartItem = items!.map((e) => e.toJson()).toList();
    return {
      "items": listCartItem,
      "payment": payment,
      "timeslot_id": timeSlotId,
      "supplier_notes":
          notes != null ? notes!.map((e) => e.toJson())?.toList() : [],
      // "vouchers": vouchers != null
      //     ? vouchers?.map((voucher) => voucher.toJson())?.toList()
      //     : null,
    };
  }

  Map<String, dynamic> toJsonAPi() {
    List<Map<String, dynamic>> listCartItem = [];
    items!.forEach((element) {
      listCartItem.add(element.toJsonApi());
    });

    Map<String, dynamic> map = {
      "payment": payment,
      "timeslot_id": timeSlotId,
      "products_list": listCartItem,
      "supplier_notes":
          notes != null ? notes!.map((e) => e.toJson())?.toList() : [],
      // "vouchers": vouchers != null
      //     ? vouchers?.map((voucher) => voucher.voucherCode)?.toList()
      //     : null,
    };
    logger.i("Order: " + map.toString());
    return map;
  }

  bool get isEmpty => items != null && items!.isEmpty;
  int itemQuantity() {
    int quantity = 0;
    for (CartItem item in items!) {
      quantity += item.quantity!;
    }
    return quantity;
  }

  void addItem(CartItem? item) {
    for (CartItem cart in items!) {
      if (cart.findCartItem(item!)) {
        cart.quantity += item.quantity;

        return;
      }
    }
    items!.add(item!);
  }

  void removeItem(CartItem item) {
    print("Quantity: ${item.quantity}");
    items!.removeWhere((element) =>
        element.findCartItem(item) && element.quantity == item.quantity);
  }

  void updateQuantity(CartItem item) {
    for (CartItem cart in items!) {
      if (cart.findCartItem(item)) {
        print("Found item");
        cart.quantity = item.quantity;
      }
    }
  }
}

class CartItem {
  ProductDTO? master;
  List<ProductDTO>? products;
  String? description;
  int quantity;

  CartItem(this.master, this.products, this.description, this.quantity);

  bool findCartItem(CartItem item) {
    bool found = true;

    if (this.master!.id != item.master!.id
        //  ||
        //     this.master.type != item.master.type
        ) {
      return false;
    }

    if (this.products!.length != item.products!.length) {
      return false;
    }
    for (int i = 0; i < this.products!.length; i++) {
      if (item.products![i].id != this.products![i].id) found = false;
    }
    if (item.description != this.description) {
      found = false;
    }
    return found;
  }

  factory CartItem.fromJson(dynamic json) {
    List<ProductDTO> list = [];
    if (json["products"] != null) {
      var itemJson = json["products"] as List;
      list = itemJson.map((e) => ProductDTO.fromJson(e)).toList();
    }
    return CartItem(
      ProductDTO.fromJson(json['master']),
      list,
      json['description'] as String,
      json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    List listProducts = products!.map((e) => e.toJson()).toList();
    return {
      "master": master!.toJson(),
      "products": listProducts,
      "description": description,
      "quantity": quantity
    };
  }

  // TODO: Xem lai quantity cua tung CartItem
  Map<String, dynamic> toJsonApi() {
    // List<Map<String, dynamic>> map = new List();
    // List productChilds = products!
    //     .map((productChild) => {
    //           "product_id": productChild.id,
    //           "product_in_menu_id": productChild.productInMenuId,
    //           "quantity": quantity, // TODO: Kiem tra lon hon max va < min
    //         })
    //     .toList();

    return {
      // "master_product": master.productInMenuId,
      // "product_childs": productChilds,
      "description": description,
      "quantity": quantity
    };

    // if (master.type != ProductType.MASTER_PRODUCT) {
    //   map.add({
    //     "product_id": master.id,
    //     "quantity": quantity,
    //     "parent_id": master.catergoryId
    //   });
    // }

    // products.forEach((element) {
    //   map.add({
    //     "product_id": element.id,
    //     "quantity": quantity,
    //     "parent_id": element.catergoryId
    //   });
    // });
    // return map;
  }
}
