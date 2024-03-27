// class TimeSlot {
//   String? id;
//   String? arriveTime;
//   String? checkoutTime;

//   TimeSlot({this.id, this.arriveTime, this.checkoutTime});

//   TimeSlot.fromJson(Map<String, dynamic> json) {
//     id = json["id"];
//     arriveTime = json["arriveTime"];
//     checkoutTime = json["checkoutTime"];
//   }

//   static List<TimeSlot> fromList(List<Map<String, dynamic>> list) {
//     return list.map((map) => TimeSlot.fromJson(map)).toList();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> _data = <String, dynamic>{};
//     _data["id"] = id;
//     _data["arriveTime"] = arriveTime;
//     _data["checkoutTime"] = checkoutTime;
//     return _data;
//   }
// }
class TimeSlotDTO {
  String? id;
  String? destinationId;
  String? closeTime;
  String? arriveTime;
  String? checkoutTime;
  bool? isActive;
  String? createAt;
  String? updateAt;

  TimeSlotDTO(
      {this.id,
      this.destinationId,
      this.closeTime,
      this.arriveTime,
      this.checkoutTime,
      this.isActive,
      this.createAt,
      this.updateAt});

  TimeSlotDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    destinationId = json["destinationId"] ?? json["destination_id"];
    closeTime = json["closeTime"] ?? json["close_time"];
    arriveTime = json["arriveTime"] ?? json["arrive_time"];
    checkoutTime = json["checkoutTime"] ?? json["checkout_time"];
    isActive = json["isActive"] ?? json["is_active"];
    createAt = json["createAt"] ?? json["create_at"];
    updateAt = json["updateAt"] ?? json["update_at"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["destinationId"] = destinationId;
    _data["closeTime"] = closeTime;
    _data["arriveTime"] = arriveTime;
    _data["checkoutTime"] = checkoutTime;
    _data["isActive"] = isActive;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    return _data;
  }
}
