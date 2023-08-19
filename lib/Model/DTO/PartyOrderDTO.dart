import 'index.dart';

class PartyOrderDTO {
  String? id;
  String? partyCode;
  TimeSlotDTO? timeSlotDTO;
  List<Party>? partyOrder;

  PartyOrderDTO({
    this.id,
    this.partyCode,
    this.timeSlotDTO,
    this.partyOrder,
  });

  PartyOrderDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    partyCode = json["partyCode"] as String;
    timeSlotDTO = json["timeSlot"] == null
        ? null
        : TimeSlotDTO.fromJson(json["timeSlot"]);
    partyOrder = json["partyOrder"] == null
        ? null
        : (json["partyOrder"] as List).map((e) => Party.fromJson(e)).toList();
  }

  static List<PartyOrderDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => PartyOrderDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["partyCode"] = partyCode;
    if (timeSlotDTO != null) {
      _data["timeSlot"] = timeSlotDTO?.toJson();
    }
    if (partyOrder != null) {
      _data["partyOrder"] = partyOrder?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Party {
  Customer? customer;
  double? totalAmount;
  int? itemQuantity;
  List<OrderDetails>? orderDetails;

  Party({
    this.customer,
    this.totalAmount,
    this.itemQuantity,
    this.orderDetails,
  });

  Party.fromJson(Map<String, dynamic> json) {
    customer =
        json["customer"] == null ? null : Customer.fromJson(json["customer"]);
    totalAmount = json["totalAmount"] ?? 0;
    itemQuantity = json["itemQuantity"];
    orderDetails = json["orderDetails"] == null
        ? null
        : (json["orderDetails"] as List)
            .map((e) => OrderDetails.fromJson(e))
            .toList();
  }

  static List<Party> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => Party.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if (customer != null) {
      _data["customer"] = customer?.toJson();
    }
    _data["totalAmount"] = totalAmount;
    _data["itemQuantity"] = itemQuantity;
    if (orderDetails != null) {
      _data["orderDetails"] = orderDetails?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}
