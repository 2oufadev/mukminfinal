import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RedeemedUserModel {
  final String username, userEmail, userToken;
  final DateTime redeemedDate, endDate;

  RedeemedUserModel(this.username, this.userEmail, this.userToken,
      this.redeemedDate, this.endDate);

  factory RedeemedUserModel.fromJson(Map<String, dynamic> json) =>
      _redeemedUserModelFromJson(json);

  Map<String, dynamic> toJson() => _redeemedUserModelToJson(this);

  @override
  String toString() => 'RedeemedUserModel<$RedeemedUserModel>';
}

RedeemedUserModel _redeemedUserModelFromJson(Map<String, dynamic> json) {
  return RedeemedUserModel(
      json['username'] as String,
      json['userEmail'] as String,
      json['userToken'] as String,
      (json['redeemedDate'] as Timestamp).toDate(),
      DateFormat("dd/MM/yyyy").parse(json['endDate']));
}

// 2
Map<String, dynamic> _redeemedUserModelToJson(RedeemedUserModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'userEmail': instance.userEmail,
      'userToken': instance.userToken,
      'redeemedDate': instance.redeemedDate,
      'endDate': DateFormat("dd/MM/yyyy").format(instance.endDate),
    };
