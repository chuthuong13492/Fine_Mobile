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

class OrderDTO {
  String? id;
  String? orderCode;
  String? partyCode;
  Customer? customer;
  DateTime? checkInDate;
  double? totalAmount;
  double? finalAmount;
  double? totalOtherAmount;
  List<OtherAmounts>? otherAmounts;
  int? orderStatus;
  int? orderType;
  TimeSlotDTO? timeSlot;
  StationDTO? stationDTO;
  int? boxQuantity;
  int? point;
  bool? isConfirm;
  bool? isPartyMode;
  int? itemQuantity;
  String? note;
  List<String>? boxesCode;
  List<OrderDetails>? orderDetails;

  OrderDTO({
    this.id,
    this.orderCode,
    this.partyCode,
    this.customer,
    this.checkInDate,
    this.totalAmount,
    this.finalAmount,
    this.totalOtherAmount,
    this.otherAmounts,
    this.orderStatus,
    this.orderType,
    this.timeSlot,
    this.stationDTO,
    this.boxQuantity,
    this.point,
    this.isConfirm,
    this.isPartyMode,
    this.itemQuantity,
    this.note,
    this.boxesCode,
    this.orderDetails,
  });

  OrderDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    orderCode = json["orderCode"];
    customer =
        json["customer"] == null ? null : Customer.fromJson(json["customer"]);
    checkInDate = json['checkInDate'] as String != null
        ? DateTime.parse(json['checkInDate'] as String)
        : null;
    totalAmount = json["totalAmount"];
    finalAmount = json["finalAmount"];
    totalOtherAmount = json["totalOtherAmount"];
    otherAmounts = json["otherAmounts"] == null
        ? null
        : (json["otherAmounts"] as List)
            .map((e) => OtherAmounts.fromJson(e))
            .toList();
    orderStatus = json["orderStatus"];
    orderType = json["orderType"];
    timeSlot = json["timeSlot"] == null
        ? null
        : TimeSlotDTO.fromJson(json["timeSlot"]);
    stationDTO = json["stationOrder"] == null
        ? null
        : StationDTO.fromJson(json["stationOrder"]);
    boxQuantity = json["boxQuantity"];
    point = json["point"];
    isConfirm = json["isConfirm"];
    isPartyMode = json["isPartyMode"];
    itemQuantity = json["itemQuantity"];
    note = json["note"];
    boxesCode =
        json['boxesCode'] != null ? List<String>.from(json['boxesCode']) : null;
    orderDetails = json["orderDetails"] == null
        ? null
        : (json["orderDetails"] as List)
            .map((e) => OrderDetails.fromJson(e))
            .toList();
  }

  static List<OrderDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OrderDTO.fromJson(map)).toList();
  }

  void addProperties(String code) {
    partyCode = code;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["orderCode"] = orderCode;
    if (customer != null) {
      _data["customer"] = customer?.toJson();
    }
    _data["totalAmount"] = totalAmount;
    _data["finalAmount"] = finalAmount;
    _data["totalOtherAmount"] = totalOtherAmount;
    if (otherAmounts != null) {
      _data["otherAmounts"] = otherAmounts?.map((e) => e.toJson()).toList();
    }
    _data["orderStatus"] = orderStatus;
    _data["orderType"] = orderType;
    if (timeSlot != null) {
      _data["timeSlot"] = timeSlot?.toJson();
    }
    // if (stationDTO != null) {
    //   _data["stationOrder"] =
    // }
    _data["point"] = point;
    _data["isConfirm"] = isConfirm;
    _data["isPartyMode"] = isPartyMode;
    _data["itemQuantity"] = itemQuantity;
    _data["note"] = note;
    if (orderDetails != null) {
      _data["orderDetails"] = orderDetails?.map((e) => e.toJson()).toList();
    }
    return _data;
  }

  Map<String, dynamic> toJsonAPi() {
    List<Map<String, dynamic>> listItem = [];
    for (var element in orderDetails!) {
      listItem.add(element.toJson());
    }
    List<Map<String, dynamic>> listOtherAmount = [];
    for (var element in otherAmounts!) {
      listOtherAmount.add(element.toJson());
    }

    Map<String, dynamic> map = {
      "id": id,
      "orderCode": orderCode,
      "partyCode": partyCode ?? null,
      "totalAmount": totalAmount,
      "finalAmount": finalAmount,
      "totalOtherAmount": totalOtherAmount,
      "orderType": orderType,
      "timeSlotId": timeSlot!.id,
      "stationId": stationDTO!.id,
      "paymentType": 1,
      "isPartyMode": isPartyMode,
      "itemQuantity": itemQuantity,
      "point": point,
      "orderDetails": listItem,
      "otherAmounts": listOtherAmount,
      // "supplier_notes":
      //     note != null ? note!.map((e) => e.toJson()).toList() : [],
      // "vouchers": vouchers != null
      //     ? vouchers?.map((voucher) => voucher.voucherCode)?.toList()
      //     : null,
    };
    logger.i("Create Order: " + map.toString());
    return map;
  }
}

class OtherAmounts {
  String? id;
  String? orderId;
  double? amount;
  int? type;

  OtherAmounts({
    this.id,
    this.orderId,
    this.amount,
    this.type,
  });

  OtherAmounts.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    orderId = json["orderId"] as String;
    amount = json["amount"];
    type = json["type"];
  }

  static List<OtherAmounts> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OtherAmounts.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["orderId"] = orderId;
    _data["amount"] = amount;
    _data["type"] = type;
    return _data;
  }
}

class OrderDetails {
  String? id;
  String? orderId;
  String? productInMenuId;
  String? productId;
  String? storeId;
  String? productCode;
  String? productName;
  double? unitPrice;
  int quantity;
  double? totalAmount;
  double? discount;
  double? finalAmount;
  String? note;
  String? imageUrl;

  OrderDetails(
      this.id,
      this.orderId,
      this.productInMenuId,
      this.productId,
      this.storeId,
      this.productCode,
      this.productName,
      this.unitPrice,
      this.imageUrl,
      this.quantity,
      this.totalAmount,
      this.discount,
      this.finalAmount,
      this.note);

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      json["id"] as String ?? null,
      json["orderId"] as String ?? null,
      json["productInMenuId"] as String,
      json["productId"] as String,
      json["storeId"] as String ?? null,
      json["productCode"] as String ?? null,
      json["productName"] as String,
      json["unitPrice"] as double,
      json["imageUrl"] as String,
      json["quantity"] as int,
      json["totalAmount"] as double,
      json["discount"] as double ?? 0,
      json["finalAmount"] as double ?? 0,
      json["note"] as String ?? '',
    );
  }

  static List<OrderDetails> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OrderDetails.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["orderId"] = orderId;
    _data["productInMenuId"] = productInMenuId;
    // _data["productId"] = productId;
    _data["storeId"] = storeId;
    _data["productCode"] = productCode;
    _data["productName"] = productName;
    _data["unitPrice"] = unitPrice;
    _data["quantity"] = quantity;
    _data["totalAmount"] = totalAmount;
    _data["finalAmount"] = finalAmount;
    _data["note"] = note ?? '';
    return _data;
  }
}

class OrderStatusDTO {
  int? orderStatus;
  String? boxId;
  String? stationName;

  OrderStatusDTO({
    this.orderStatus,
    this.boxId,
    this.stationName,
  });

  OrderStatusDTO.fromJson(Map<String, dynamic> json) {
    orderStatus = json["orderStatus"] as int;
    boxId = json["boxId"] as String;
    stationName = json["stationName"] as String ?? null;
  }

  static List<OrderStatusDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OrderStatusDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["orderStatus"] = orderStatus;
    _data["boxId"] = boxId;
    _data["stationName"] = stationName;
    return _data;
  }
}

class ReOrderDTO {
  String? id;
  DateTime? checkInDate;
  int? itemQuantity;
  String? stationName;
  List<ProductInReOrder>? listProductNameInReOrder;

  ReOrderDTO({
    this.id,
    this.checkInDate,
    this.itemQuantity,
    this.stationName,
    this.listProductNameInReOrder,
  });

  ReOrderDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    checkInDate = json['checkInDate'] as String != null
        ? DateTime.parse(json['checkInDate'] as String)
        : null;
    itemQuantity = json["itemQuantity"];
    stationName = json["stationName"];
    listProductNameInReOrder = json["listProductInReOrder"] == null
        ? null
        : (json["listProductInReOrder"] as List)
            .map((e) => ProductInReOrder.fromJson(e))
            .toList();
  }
}

class ProductInReOrder {
  String? productName;
  String? imageUrl;

  ProductInReOrder({
    this.productName,
    this.imageUrl,
  });

  ProductInReOrder.fromJson(Map<String, dynamic> json) {
    productName = json["productName"];
    imageUrl = json["imageUrl"];
  }
}
