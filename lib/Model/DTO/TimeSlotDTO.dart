class TimeSlot {
  String? id;
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
