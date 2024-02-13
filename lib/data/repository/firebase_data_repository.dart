import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mukim_app/data/models/firebase_sponsor_model.dart';
import 'package:mukim_app/data/models/firebase_user_model.dart';
import 'package:mukim_app/data/models/redeemed_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseDataRepository {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');

  final CollectionReference sponsorsCollection =
      FirebaseFirestore.instance.collection('SponsorsList');

  Future<void> addUser(FirebaseUserModel firebaseUserModel) {
    return usersCollection
        .doc(firebaseUserModel.uid)
        .set(firebaseUserModel.toJson(), SetOptions(merge: true));
  }

  Future<DocumentReference> addSponsorCoupon(
      FirebaseSponsorModel firebaseSponsorModel) {
    return sponsorsCollection.add(firebaseSponsorModel);
  }

  Future<QuerySnapshot> getUserDataByToken(String token) async {
    return await usersCollection.where('UID', isEqualTo: token).get();
  }

  Future<bool> redeemCoupon(FirebaseSponsorModel firebaseSponsorModel,
      String username, String email, String token) async {
    try {
      RedeemedUserModel redeemedUserModel = RedeemedUserModel(username, email,
          token, DateTime.now(), DateTime.now().add(Duration(days: 365)));
      final result =
          await sponsorsCollection.doc(firebaseSponsorModel.id).update({
        'redeemedUsers': FieldValue.arrayUnion(
          [redeemedUserModel.toJson()],
        )
      });
      DocumentSnapshot documentSnapshot =
          await sponsorsCollection.doc(firebaseSponsorModel.id).get();
      String slots = (documentSnapshot.data() as Map)['slots'].toString();
      int slotsInt = int.parse(slots);
      int remainingSlots = slotsInt - 1;

      await sponsorsCollection
          .doc(firebaseSponsorModel.id)
          .set({'slots': remainingSlots.toString()}, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getCouponsIds(String userId) async {
    List<dynamic> couponsIds = [];
    print(userId);
    DocumentSnapshot<Object?> snapshot =
        await usersCollection.doc(userId).get();
    couponsIds = snapshot.get('sponsorsList') as List<dynamic>;
    return couponsIds;
  }

  Future<List<FirebaseSponsorModel>> getCouponsList(
      List<dynamic> couponsIdsList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('useremail');
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('SponsorsList')
        .where('userEmail', isEqualTo: userEmail)
        .get();
    List<FirebaseSponsorModel> couponsList = [];
    if (querySnapshot != null && querySnapshot.docs != null) {
      print('1111111');
      print(querySnapshot.docs.length);
      couponsList = querySnapshot.docs
          .map((e) =>
              FirebaseSponsorModel.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    } else {
      print('222222');
    }

    // List<FirebaseSponsorModel> couponsList = [];
    // if (couponsIdsList != null && couponsIdsList.isNotEmpty) {
    //   for (String coupon in couponsIdsList) {
    //     DocumentSnapshot snapshot = await sponsorsCollection.doc(coupon).get();
    //     FirebaseSponsorModel firebaseSponsorModel =
    //         FirebaseSponsorModel.fromJson(snapshot.data());
    //     QuerySnapshot querySnapshot =
    //         await snapshot.reference.collection('RedeemedUsers').get();
    //     List<QueryDocumentSnapshot> queryDocumentSnapshot = querySnapshot.docs;

    //     firebaseSponsorModel.redeemedUsers = queryDocumentSnapshot
    //         .map((e) => RedeemedUserModel.fromJson(e.data()))
    //         .toList();
    //     couponsList.add(firebaseSponsorModel);
    //   }
    // }

    return couponsList;
  }

  Future<FirebaseSponsorModel?> checkSponsorCoupon(String coupon) async {
    print(coupon);
    final reference = await sponsorsCollection
        .where('code', isEqualTo: coupon)
        .where('slots', isGreaterThan: "0")
        .get();
    if (reference != null) {
      print(reference.docs.length);
      if (reference.docs != null && reference.docs.isNotEmpty) {
        FirebaseSponsorModel firebaseSponsorModel =
            FirebaseSponsorModel.fromJson(
                reference.docs.first.data() as Map<String, dynamic>);
        firebaseSponsorModel.id = reference.docs.first.id;
        print(firebaseSponsorModel.toJson());

        if (firebaseSponsorModel.slots != null &&
            firebaseSponsorModel.slots != 0) {
          return firebaseSponsorModel;
        }
      }
    }
    return null;
  }
}
