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
