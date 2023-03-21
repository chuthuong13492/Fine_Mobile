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

class OrderDTO {
  int? id;
  String? orderCode;
  Customer? customer;
  String? deliveryPhone;
  String? checkInDate;
  double? totalAmount;
  double? discount;
  double? finalAmount;
  double? shippingFee;
  int? orderStatus;
  int? orderType;
  TimeSlot? timeSlot;
  Room? room;
  bool? isConfirm;
  bool? isPartyMode;
  int? shipperId;
  String? note;
  List<InverseGeneralOrder>? inverseGeneralOrder;

  OrderDTO(
      {this.id,
      this.orderCode,
      this.customer,
      this.deliveryPhone,
      this.checkInDate,
      this.totalAmount,
      this.discount,
      this.finalAmount,
      this.shippingFee,
      this.orderStatus,
      this.orderType,
      this.timeSlot,
      this.room,
      this.isConfirm,
      this.isPartyMode,
      this.shipperId,
      this.note,
      this.inverseGeneralOrder});

  OrderDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    orderCode = json["orderCode"];
    customer =
        json["customer"] == null ? null : Customer.fromJson(json["customer"]);
    deliveryPhone = json["deliveryPhone"];
    checkInDate = json["checkInDate"];
    totalAmount = json["totalAmount"];
    discount = json["discount"];
    finalAmount = json["finalAmount"];
    shippingFee = json["shippingFee"];
    orderStatus = json["orderStatus"];
    orderType = json["orderType"];
    timeSlot =
        json["timeSlot"] == null ? null : TimeSlot.fromJson(json["timeSlot"]);
    room = json["room"] == null ? null : Room.fromJson(json["room"]);
    isConfirm = json["isConfirm"];
    isPartyMode = json["isPartyMode"];
    shipperId = json["shipperId"] ?? null;
    note = json["note"];
    inverseGeneralOrder = json["inverseGeneralOrder"] == null
        ? null
        : (json["inverseGeneralOrder"] as List)
            .map((e) => InverseGeneralOrder.fromJson(e))
            .toList();
  }

  static List<OrderDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OrderDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["orderCode"] = orderCode;
    if (customer != null) {
      _data["customer"] = customer?.toJson();
    }
    _data["deliveryPhone"] = deliveryPhone;
    _data["checkInDate"] = checkInDate;
    _data["totalAmount"] = totalAmount;
    _data["discount"] = discount;
    _data["finalAmount"] = finalAmount;
    _data["shippingFee"] = shippingFee;
    _data["orderStatus"] = orderStatus;
    _data["orderType"] = orderType;
    if (timeSlot != null) {
      _data["timeSlot"] = timeSlot?.toJson();
    }
    if (room != null) {
      _data["room"] = room?.toJson();
    }
    _data["isConfirm"] = isConfirm;
    _data["isPartyMode"] = isPartyMode;
    _data["shipperId"] = shipperId;
    _data["note"] = note;
    if (inverseGeneralOrder != null) {
      _data["inverseGeneralOrder"] =
          inverseGeneralOrder?.map((e) => e.toJson()).toList();
    }
    return _data;
  }

  Map<String, dynamic> toJsonAPi() {
    List<Map<String, dynamic>> listItem = [];
    inverseGeneralOrder!.forEach((element) {
      listItem.add(element.toJson());
    });

    Map<String, dynamic> map = {
      "orderCode": orderCode,
      "deliveryPhone": deliveryPhone,
      "checkInDate": checkInDate,
      "totalAmount": totalAmount,
      "discount": discount ?? 0,
      "finalAmount": finalAmount,
      "shippingFee": shippingFee,
      "orderStatus": orderStatus,
      "orderType": orderType,
      "customerId": customer!.id,
      "timeSlotId": timeSlot!.id,
      "roomId": room!.id,
      "note": note ?? '',
      "isConfirm": isConfirm,
      "isPartyMode": isPartyMode,
      "shipperId": shipperId,
      "inverseGeneralOrder": listItem
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

class InverseGeneralOrder {
  int? id;
  int? generalOrderId;
  String? orderCode;
  double? totalAmount;
  double? discount;
  double? finalAmount;
  int? orderStatus;
  int? storeId;
  String? storeName;
  List<OrderDetails>? orderDetails;

  InverseGeneralOrder(
      {this.id,
      this.generalOrderId,
      this.orderCode,
      this.totalAmount,
      this.discount,
      this.finalAmount,
      this.orderStatus,
      this.storeId,
      this.storeName,
      this.orderDetails});

  InverseGeneralOrder.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    generalOrderId = json["generalOrderId"];
    orderCode = json["orderCode"];
    totalAmount = json["totalAmount"];
    discount = json["discount"];
    finalAmount = json["finalAmount"];
    orderStatus = json["orderStatus"];
    storeId = json["storeId"];
    storeName = json["storeName"] ?? null;
    orderDetails = json["orderDetails"] == null
        ? null
        : (json["orderDetails"] as List)
            .map((e) => OrderDetails.fromJson(e))
            .toList();
  }

  static List<InverseGeneralOrder> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => InverseGeneralOrder.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["generalOrderId"] = generalOrderId;
    _data["orderCode"] = orderCode;
    _data["totalAmount"] = totalAmount;
    _data["discount"] = discount ?? 0;
    _data["finalAmount"] = finalAmount;
    _data["orderStatus"] = orderStatus;
    _data["storeId"] = storeId;
    _data["storeName"] = storeName;
    if (orderDetails != null) {
      _data["orderDetails"] = orderDetails?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class OrderDetails {
  int? id;
  int? orderId;
  int? productInMenuId;
  String? productCode;
  String? productName;
  int? comboId;
  double? unitPrice;
  int quantity;
  double? totalAmount;
  double? discount;
  double? finalAmount;
  String? note;

  OrderDetails(
      this.id,
      this.orderId,
      this.productInMenuId,
      this.productCode,
      this.productName,
      this.comboId,
      this.unitPrice,
      this.quantity,
      this.totalAmount,
      this.discount,
      this.finalAmount,
      this.note);

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
        json["id"] as int,
        json["orderId"] as int,
        json["productInMenuId"] as int,
        json["productCode"] as String,
        json["productName"] as String,
        json["comboId"] as int ?? null,
        json["unitPrice"] as double,
        json["quantity"] as int,
        json["totalAmount"] as double,
        json["discount"] as double ?? 0,
        json["finalAmount"] as double,
        json["note"] as String ?? '');
    // id = json["id"];
    // orderId = json["orderId"];
    // productInMenuId = json["productInMenuId"];
    // productCode = json["productCode"];
    // productName = json["productName"];
    // comboId = json["comboId"];
    // unitPrice = json["unitPrice"];
    // quantity = json["quantity"];
    // totalAmount = json["totalAmount"];
    // discount = json["discount"];
    // finalAmount = json["finalAmount"];
    // note = json["note"];
  }

  static List<OrderDetails> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => OrderDetails.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["orderId"] = orderId;
    _data["productInMenuId"] = productInMenuId;
    _data["productCode"] = productCode;
    _data["productName"] = productName;
    // _data["comboId"] = comboId;
    _data["comboId"] = null;
    _data["unitPrice"] = unitPrice;
    _data["quantity"] = quantity;
    _data["totalAmount"] = totalAmount;
    _data["discount"] = discount ?? 0;
    _data["finalAmount"] = finalAmount;
    _data["note"] = note ?? '';
    return _data;
  }
}

class Room {
  int? id;
  int? roomNumber;
  int? floorNumber;
  String? areaName;

  Room({this.id, this.roomNumber, this.floorNumber, this.areaName});

  Room.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    roomNumber = json["roomNumber"];
    floorNumber = json["floorNumber"];
    areaName = json["areaName"];
  }

  static List<Room> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => Room.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["roomNumber"] = roomNumber;
    _data["floorNumber"] = floorNumber;
    _data["areaName"] = areaName;
    return _data;
  }
}

class TimeSlot {
  int? id;
  String? arriveTime;
  String? checkoutTime;

  TimeSlot({this.id, this.arriveTime, this.checkoutTime});

  TimeSlot.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    arriveTime = json["arriveTime"];
    checkoutTime = json["checkoutTime"];
  }

  static List<TimeSlot> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => TimeSlot.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["arriveTime"] = arriveTime;
    _data["checkoutTime"] = checkoutTime;
    return _data;
  }
}

class Customer {
  int? id;
  String? name;
  String? customerCode;
  String? email;

  Customer({this.id, this.name, this.customerCode, this.email});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    customerCode = json["customerCode"];
    email = json["email"];
  }

  static List<Customer> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => Customer.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["customerCode"] = customerCode;
    _data["email"] = email;
    return _data;
  }
}
