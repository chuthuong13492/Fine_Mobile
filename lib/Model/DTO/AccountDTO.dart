class AccountDTO {
  int? id;
  String? name;
  String? customerCode;
  String? email;
  String? phone;
  DateTime? dateOfBirth;
  String? imageUrl;
  int? campusId;
  int? campusInfoId;
  String? createAt;
  String? updateAt;

  AccountDTO(
      {this.id,
      this.name,
      this.customerCode,
      this.email,
      this.phone,
      this.dateOfBirth,
      this.imageUrl,
      this.campusId,
      this.campusInfoId,
      this.createAt,
      this.updateAt});

  AccountDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    customerCode = json['customerCode'];
    email = json['email'];
    phone = json['phone'];
    dateOfBirth = json['dateOfBirth'] as String != null
        ? DateTime.parse(json['dateOfBirth'] as String)
        : null;
    imageUrl = json['imageUrl'];
    campusId = json['campusId'];
    campusInfoId = json['campusInfoId'];
    createAt = json['createAt'];
    updateAt = json['updateAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['customerCode'] = this.customerCode;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['dateOfBirth'] = this.dateOfBirth.toString();
    data['imageUrl'] = this.imageUrl;
    data['campusId'] = this.campusId;
    data['campusInfoId'] = this.campusInfoId;
    data['createAt'] = this.createAt;
    data['updateAt'] = this.updateAt;
    return data;
  }
}
