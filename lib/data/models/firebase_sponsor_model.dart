import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mukim_app/data/models/redeemed_user_model.dart';

class FirebaseSponsorModel {
  final String code, username, userEmail, userToken, notes;
  final String slots;
  final DateTime createdDate;

  List<RedeemedUserModel> redeemedUsers;
  String? id;

  FirebaseSponsorModel(this.code, this.username, this.userEmail, this.notes,
      this.userToken, this.slots, this.createdDate, this.redeemedUsers,
      {this.id});

  factory FirebaseSponsorModel.fromJson(Map<String, dynamic> json) =>
      _firebaseSponsorModelFromJson(json);

  Map<String, dynamic> toJson() => _firebaseSponsorModelToJson(this);

  @override
  String toString() => 'FirebaseSponsorModel<$FirebaseSponsorModel>';
}

FirebaseSponsorModel _firebaseSponsorModelFromJson(Map<String, dynamic> json) {
  return FirebaseSponsorModel(
      json['code'] as String,
      json['username'] as String,
      json['userEmail'] as String,
      json['notes'] as String,
      json['userToken'] as String,
      json['slots'] as String,
      (json['createdDate'] as Timestamp).toDate(),
      json['redeemedUsers'] != null
          ? (json['redeemedUsers'] as List<dynamic>)
              .map((e) => RedeemedUserModel.fromJson(e))
              .toList()
          : [],
      id: json['id'] != null ? json['id'] : '');
}

//
Map<String, dynamic> _firebaseSponsorModelToJson(
        FirebaseSponsorModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'username': instance.username,
      'userEmail': instance.userEmail,
      'notes': instance.notes,
      'userToken': instance.userToken,
      'slots': instance.slots,
      'createdDate': instance.createdDate,
      'id': instance.id,
      'redeemedUsers':
          instance.redeemedUsers != null ? instance.redeemedUsers : []
    };
