import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserModel {
  final String uid, username, userEmail, userToken;
  final List? sponsorsList;

  FirebaseUserModel(this.uid, this.username, this.userEmail, this.userToken,
      {this.sponsorsList});

  factory FirebaseUserModel.fromJson(Map<String, dynamic> json) =>
      _firebaseUserModelFromJson(json);

  Map<String, dynamic> toJson() => _firebaseUserModelToJson(this);

  @override
  String toString() => 'FirebaseUserModel<$FirebaseUserModel>';
}

FirebaseUserModel _firebaseUserModelFromJson(Map<String, dynamic> json) {
  return FirebaseUserModel(
    json['UID'] as String,
    json['username'] as String,
    json['email'] as String,
    json['token'] as String,
    sponsorsList: json['sponsorsList'] != null
        ? json['sponsorsList'] as List<dynamic>
        : null,
  );
}

// 2
Map<String, dynamic> _firebaseUserModelToJson(FirebaseUserModel instance) =>
    <String, dynamic>{
      'UID': instance.uid,
      'username': instance.username,
      if (instance.userEmail != null && instance.userEmail.isNotEmpty)
        'email': instance.userEmail,
      'token': instance.userToken,
      if (instance.sponsorsList != null) 'sponsorsList': instance.sponsorsList,
    };
