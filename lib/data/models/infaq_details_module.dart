class InfaqDetailsModel {
  int? id;
  int? categoryId;
  String? organizationName;
  int? maybankNo;
  String? introduction;
  String? background;
  List<String>? websiteLink;
  String? image;
  int? order;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? bankName;

  InfaqDetailsModel(
      {this.id,
      this.categoryId,
      this.organizationName,
      this.maybankNo,
      this.introduction,
      this.background,
      this.websiteLink,
      this.image,
      this.order,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.bankName});

  InfaqDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    organizationName = json['organization_name'];
    maybankNo = json['maybank_no'];
    introduction = json['introduction'];
    background = json['background'];
    websiteLink = json['website_link'].cast<String>();
    image = json['image'];
    order = json['order'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bankName = json['bank_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['organization_name'] = this.organizationName;
    data['maybank_no'] = this.maybankNo;
    data['introduction'] = this.introduction;
    data['background'] = this.background;
    data['website_link'] = this.websiteLink;
    data['image'] = this.image;
    data['order'] = this.order;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['bank_name'] = this.bankName;
    return data;
  }
}
