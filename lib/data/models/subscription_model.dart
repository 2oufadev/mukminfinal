class SubscriptionModel {
  int? id;
  int? customerId;
  int? sponsorId;
  String? package;
  String? paymentStatus;
  String? period;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? email;

  SubscriptionModel(
      {this.id,
      this.customerId,
      this.sponsorId,
      this.package,
      this.paymentStatus,
      this.period,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.email});

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    sponsorId = json['sponsor_id'];
    package = json['package'];
    paymentStatus = json['payment_status'];
    period = json['period'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['sponsor_id'] = this.sponsorId;
    data['package'] = this.package;
    data['payment_status'] = this.paymentStatus;
    data['period'] = this.period;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['email'] = this.email;
    return data;
  }
}
