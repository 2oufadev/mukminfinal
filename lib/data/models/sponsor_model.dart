class SponsorModel {
  int? id;
  String? name;
  int? customerId;
  String? status;
  String? package;
  String? quantity;
  int? remaining;
  String? notes;
  String? createdAt;
  String? updatedAt;
  String? coupon;

  SponsorModel(
      {this.id,
      this.name,
      this.customerId,
      this.status,
      this.package,
      this.quantity,
      this.remaining,
      this.notes,
      this.createdAt,
      this.updatedAt,
      this.coupon});

  SponsorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    customerId = json['customer_id'];
    status = json['status'];
    package = json['package'];
    quantity = json['quantity'];
    remaining = json['remaining'];
    notes = json['notes'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['coupon'] != null) {
      coupon = json['coupon'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['customer_id'] = this.customerId;
    data['status'] = this.status;
    data['package'] = this.package;
    data['quantity'] = this.quantity;
    data['remaining'] = this.remaining;
    data['notes'] = this.notes;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.coupon != null) {
      data['coupon'] = coupon;
    }
    return data;
  }
}
