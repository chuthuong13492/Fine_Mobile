class BoxDTO {
  String? key;
  String? value;

  BoxDTO({
    this.key,
    this.value,
  });

  BoxDTO.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;

    return data;
  }
}
