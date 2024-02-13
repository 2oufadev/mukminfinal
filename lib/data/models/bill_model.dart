class BillModel {
  String? id;
  String? collectionId;
  bool? paid;
  String? state;
  int? amount;
  int? paidAmount;
  String? dueAt;
  String? email;
  String? mobile;
  String? name;
  String? url;
  String? reference1Label;
  String? reference1;
  String? reference2Label;
  String? reference2;
  String? redirectUrl;
  String? callbackUrl;
  String? description;
  String? paidAt;

  BillModel(
      {this.id,
      this.collectionId,
      this.paid,
      this.state,
      this.amount,
      this.paidAmount,
      this.dueAt,
      this.email,
      this.mobile,
      this.name,
      this.url,
      this.reference1Label,
      this.reference1,
      this.reference2Label,
      this.reference2,
      this.redirectUrl,
      this.callbackUrl,
      this.description,
      this.paidAt});

  BillModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    collectionId = json['collection_id'];
    paid = json['paid'];
    state = json['state'];
    amount = json['amount'];
    paidAmount = json['paid_amount'];
    dueAt = json['due_at'];
    email = json['email'];
    mobile = json['mobile'];
    name = json['name'];
    url = json['url'];
    reference1Label = json['reference_1_label'];
    reference1 = json['reference_1'];
    reference2Label = json['reference_2_label'];
    reference2 = json['reference_2'];
    redirectUrl = json['redirect_url'];
    callbackUrl = json['callback_url'];
    description = json['description'];
    paidAt = json['paid_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['collection_id'] = this.collectionId;
    data['paid'] = this.paid;
    data['state'] = this.state;
    data['amount'] = this.amount;
    data['paid_amount'] = this.paidAmount;
    data['due_at'] = this.dueAt;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['name'] = this.name;
    data['url'] = this.url;
    data['reference_1_label'] = this.reference1Label;
    data['reference_1'] = this.reference1;
    data['reference_2_label'] = this.reference2Label;
    data['reference_2'] = this.reference2;
    data['redirect_url'] = this.redirectUrl;
    data['callback_url'] = this.callbackUrl;
    data['description'] = this.description;
    data['paid_at'] = this.paidAt;
    return data;
  }
}
