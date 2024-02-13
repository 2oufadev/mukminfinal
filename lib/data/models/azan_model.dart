class AzanModel {
  int? id;
  String? name;
  String? audio;
  String? type;
  String? order;
  String? status;
  String? createdAt;
  String? updatedAt;

  AzanModel(
      {this.id,
      this.name,
      this.audio,
      this.type,
      this.order,
      this.status,
      this.createdAt,
      this.updatedAt});

  AzanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    audio = json['audio'];
    type = json['type'];
    order = json['order'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['audio'] = this.audio;
    data['type'] = this.type;
    data['order'] = this.order;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
