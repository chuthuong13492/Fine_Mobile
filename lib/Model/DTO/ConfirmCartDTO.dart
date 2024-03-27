import 'package:logger/logger.dart';

final logger = Logger(
    printer: PrettyPrinter(
  methodCount: 0,
  errorMethodCount: 5,
  lineLength: 50,
  colors: true,
  printEmojis: true,
  printTime: false,
));

class ConfirmCart {
  List<ConfirmCartItem>? orderDetails;
  int? orderType;
  int? partyType;
  String? timeSlotId;
  String? productId;
  String? partyCode;
  int? quantity;

  ConfirmCart.get({
    this.productId,
    this.quantity,
    this.orderType,
    this.partyType,
    this.partyCode,
    this.timeSlotId,
    this.orderDetails,
  });

  ConfirmCart({
    this.productId,
    this.quantity,
    this.orderType,
    this.partyType,
    this.timeSlotId,
    this.partyCode,
  }) {
    orderDetails = [];
  }

  factory ConfirmCart.fromJson(dynamic json) {
    List<ConfirmCartItem> list = [];
    if (json["card"] != null) {
      if (json["card"].length != 0) {
        var itemJson = json["card"] as List;
        list = itemJson.map((e) => ConfirmCartItem.fromJson(e)).toList();
      }
    }

    if (json["orderDetails"] != null) {
      var itemJson = json["orderDetails"] as List;
      list = itemJson.map((e) => ConfirmCartItem.fromJson(e)).toList();
    }
    return ConfirmCart.get(
      orderType: json["orderType"] ?? 1,
      partyType: json["partyType"] ?? 1,
      productId: json["productId"],
      quantity: json["quantity"],
      timeSlotId: json['timeSlotId'],
      orderDetails: list,
    );
  }

  void addProperties(int? typeOrder, {int? typeParty}) {
    orderType = typeOrder;
    // timeSlotId = timeSlot;
    partyType = typeParty;
  }

  Map<String, dynamic> toJson() {
    List listCartItem = orderDetails!.map((e) => e.toJson()).toList();
    return {
      "orderType": orderType,
      "timeSlotId": timeSlotId,
      "orderDetails": listCartItem,
    };
  }

  Map<String, dynamic> toCheckCartJsonAPi() {
    List<Map<String, dynamic>> listCartItem = [];
    if (orderDetails != null) {
      orderDetails!.forEach((element) {
        listCartItem.add(element.toJson());
      });
    }
    Map<String, dynamic> map = {
      "productId": productId,
      "quantity": quantity,
      "timeSlotId": timeSlotId,
      "card": listCartItem ?? null,
    };
    logger.i("Mart: " + map.toString());
    return map;
  }

  Map<String, dynamic> toJsonAPi() {
    List<Map<String, dynamic>> listCartItem = [];
    if (orderDetails != null) {
      orderDetails!.forEach((element) {
        listCartItem.add(element.toJson());
      });
    }
    Map<String, dynamic> map = {
      "orderType": orderType,
      "partyType": partyType ?? null,
      "partyCode": partyCode ?? "",
      "timeSlotId": timeSlotId,
      "orderDetails": listCartItem ?? null,
    };
    logger.i("Mart: " + map.toString());
    return map;
  }

  bool get isEmpty => orderDetails != null && orderDetails!.isEmpty;
  int itemQuantity() {
    int quantity = 0;
    for (ConfirmCartItem item in orderDetails!) {
      quantity += item.quantity;
    }
    return quantity;
  }

  void addItem(ConfirmCartItem item) {
    for (ConfirmCartItem cart in orderDetails!) {
      if (cart.findCartItem(item)) {
        cart.quantity += item.quantity;

        return;
      }
    }
    orderDetails!.add(item);
  }

  void removeItem(ConfirmCartItem item) {
    print("Quantity: ${item.quantity}");
    orderDetails!.removeWhere((element) => element.findCartItem(item));
  }

  void updateQuantity(ConfirmCartItem item) {
    for (ConfirmCartItem cart in orderDetails!) {
      if (cart.findCartItem(item)) {
        print("Found item");
        cart.quantity = item.quantity;
      }
    }
  }
}

class ConfirmCartItem {
  String? productId;
  int quantity;
  String? note;

  ConfirmCartItem(this.productId, this.quantity, this.note);

  bool findCartItem(ConfirmCartItem item) {
    bool found = true;

    if (this.productId != item.productId) {
      return false;
    }
    return found;
  }

  factory ConfirmCartItem.fromJson(Map<String, dynamic> json) {
    return ConfirmCartItem(
      json['productId'] as String,
      json['quantity'] as int,
      json['note'] as String,
    );
  }

  static List<ConfirmCartItem> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => ConfirmCartItem.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["productId"] = productId;
    _data["quantity"] = quantity;
    _data["note"] = note ?? "";
    return _data;
  }
}
