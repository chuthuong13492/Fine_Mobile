class Customer {
  String? id;
  String? name;
  String? customerCode;
  String? email;
  String? phone;
  bool? isAdmin;
  bool? isConfirm;

  Customer({this.id, this.name, this.customerCode, this.email, this.phone});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    name = json["name"];
    customerCode = json["customerCode"];
    email = json["email"];
    phone = json["phone"];
    isAdmin = json["isAdmin"] ?? false;
    isConfirm = json["isConfirm"] ?? false;
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
    _data["phone"] = phone;
    return _data;
  }
}
