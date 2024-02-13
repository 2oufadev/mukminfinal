class OneDayHadithModel {
  int? id;
  int? categoryId;
  int? shown;
  String? hadithName;
  String? categoryName;
  String? hadithImage;
  String? description;

  OneDayHadithModel(this.id, this.categoryId, this.shown, this.hadithName,
      this.categoryName, this.hadithImage, this.description);

  OneDayHadithModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    categoryId = json["categoryId"];
    shown = json["shown"];
    hadithName = json["hadithName"];
    categoryName = json["categoryName"];
    hadithImage = json["hadithImage"];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "categoryId": this.categoryId,
      "shown": this.shown,
      "hadithName": this.hadithName,
      "categoryName": this.categoryName,
      "hadithImage": this.hadithImage,
      "description": this.description
    };
  }
}
