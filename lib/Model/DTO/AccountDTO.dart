class AccountDTO {
  String? id;
  String? name;
  String? customerCode;
  String? email;
  String? phone;
  double? balance;
  DateTime? dateOfBirth;
  String? imageUrl;
  // bool? isFirstLogin;
  // int? universityId;
  // int? uniInfoId;
  DateTime? createAt;
  DateTime? updateAt;

  AccountDTO(
      {this.id,
      this.name,
      this.customerCode,
      this.email,
      this.phone,
      this.balance,
      this.dateOfBirth,
      this.imageUrl,
      // this.isFirstLogin = true,
      // this.universityId,
      // this.uniInfoId,
      this.createAt,
      this.updateAt});

  AccountDTO.fromJson(Map<String, dynamic> json) {
    id = json["id"] as String;
    name = json["name"];
    customerCode = json["customerCode"];
    email = json["email"];
    phone = json["phone"] ?? null;
    balance = json["balance"] ?? null;
    dateOfBirth = json['dateOfBirth'] as String != null
        ? DateTime.parse(json['dateOfBirth'] as String)
        : null;
    imageUrl = json["imageUrl"];
    // isFirstLogin:
    // (json['isFirstLogin'] as bool) ?? false;
    // universityId = json["universityId"];
    // uniInfoId = json["uniInfoId"];
    createAt = json['createAt'] as String != null
        ? DateTime.parse(json['createAt'] as String)
        : null;
    updateAt = json['updateAt'] as String != null
        ? DateTime.parse(json['updateAt'] as String)
        : null;
  }

  static List<AccountDTO> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => AccountDTO.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["customerCode"] = customerCode;
    _data["email"] = email;
    _data["phone"] = phone;
    _data["dateOfBirth"] = dateOfBirth;
    _data["imageUrl"] = imageUrl;
    // _data["universityId"] = universityId;
    // _data["uniInfoId"] = uniInfoId;
    _data["createAt"] = createAt;
    _data["updateAt"] = updateAt;
    return _data;
  }
}
