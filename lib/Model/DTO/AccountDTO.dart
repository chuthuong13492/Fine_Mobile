class AccountDTO {
  int? id;
  String? name;
  String? phone;
  String? email;
  int? brandId;
  DateTime? dateOfBirth;
  String? imageUrl;

  AccountDTO(
      {this.id,
      this.name,
      this.phone,
      this.email,
      this.brandId,
      this.dateOfBirth,
      this.imageUrl});

  AccountDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    brandId = json['brandId'];
    dateOfBirth = DateTime.parse(json['dateOfBirth'] as String);
    imageUrl = json['imageUrl'];
  }
  // factory AccountDTO.fromJson(dynamic json) => AccountDTO(
  //       id: json["id"],
  //       name: json['name'] as String,
  //       email: json['email'] as String,
  //       phone: json['phone'] as String,
  //       brandId: json['brandId'],
  //       imageUrl: json['imageUrl'] as String,
  //       // gender: (json['gender']),
  //       // balance: json['balance'],
  //       // point: json['point'],
  //       // isFirstLogin: (json['is_first_login'] as bool) ?? false,
  //       // ignore: unnecessary_null_comparison
  //       // dateOfBirth: json['dateOfBirth'] as String != null ? DateTime.parse(json['dateOfBirth'] as String) : '',
  //       dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),

  //       // referalCode: json['ref_code']
  //     );

  // static List<AccountDTO> fromList(dynamic jsonList) {
  //   var list = jsonList as List;
  //   return list.map((map) => AccountDTO.fromJson(map)).toList();
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['brandId'] = this.brandId;
    data['dateOfBirth'] = this.dateOfBirth;
    data['imageUrl'] = this.imageUrl;
    return data;
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     "id": id.toString(),
  //     "name": name,
  //     "email": email,
  //     "phone": phone,
  //     // "gender": gender,
  //     "dateOfBirth": dateOfBirth?.toString(),
  //     "imageUrl": imageUrl,
  //     // "ref_code": referalCode
  //   };
  // }
}
