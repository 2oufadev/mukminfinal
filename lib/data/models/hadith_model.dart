class HadithModel {
  List<Data>? data;
  List<SubImages>? subImages;

  HadithModel({this.data, this.subImages});

  HadithModel.fromJson(Map<String, dynamic> json) {
    data = <Data>[];
    json['data'].forEach((v) {
      data!.add(new Data.fromJson(v));
    });

    subImages = <SubImages>[];
    json['sub_images'].forEach((v) {
      subImages!.add(new SubImages.fromJson(v));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.subImages != null) {
      data['sub_images'] = this.subImages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? categoryId;
  String? name;
  String? description;
  String? urlLink;
  String? image;
  String? galleryImages;
  int? order;
  String? status;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.categoryId,
      this.name,
      this.description,
      this.urlLink,
      this.image,
      this.galleryImages,
      this.order,
      this.status,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    name = json['name'];
    description = json['description'];
    urlLink = json['ref_link'];
    image = json['image'];
    galleryImages = json['gallery_images'];
    order = json['order'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['ref_link'] = this.urlLink;
    data['image'] = this.image;
    data['gallery_images'] = this.galleryImages;
    data['order'] = this.order;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class SubImages {
  int? id;
  int? parentId;
  String? image;
  String? reference;
  int? order;
  String? tableName;
  String? createdAt;
  String? updatedAt;

  SubImages(
      {this.id,
      this.parentId,
      this.image,
      this.reference,
      this.order,
      this.tableName,
      this.createdAt,
      this.updatedAt});

  SubImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    image = json['image'];
    reference = json['reference'];
    order = json['order'];
    tableName = json['table_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent_id'] = this.parentId;
    data['image'] = this.image;
    data['reference'] = this.reference;
    data['order'] = this.order;
    data['table_name'] = this.tableName;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ReadyHadithModel {
  int? id;
  int? categoryId;
  String? name;
  String? description;
  String? urlLink;
  String? image;
  List<SubImages>? galleryImages;
  int? order;
  String? status;
  String? createdAt;
  String? updatedAt;
  ReadyHadithModel({
    this.id,
    this.categoryId,
    this.name,
    this.description,
    this.urlLink,
    this.image,
    this.galleryImages,
    this.order,
    this.status,
    this.createdAt,
    this.updatedAt,
  });
}
