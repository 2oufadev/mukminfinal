import 'dart:convert';

import 'package:mukim_app/data/api/api_client.dart';

class PaymentApi {
  static const BASE_URL = 'https://www.billplz.com/api/';
  static const Api_Key = 'df5cd2b0-924a-498a-9ac5-7de80625cfd7';
  static const testAuth = BASE_URL + 'v4/webhook_rank';
  static const bill_url = BASE_URL + 'v3/bills';
  static const collectionId = 'gkn1xq0z';
  static const subscription_callback_url =
      'https://salam.mukminapps.com/api/subscription/payment/notify_url';
  static const sponsor_callback_url =
      'https://salam.mukminapps.com/api/sponsor/payment/notify_url';
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$Api_Key'));

  Future<dynamic> createSubscriptionBill(
      String email, String name, String amount, String description) async {
    Map<String, String> parameters = {
      'collection_id': 'lm47vgoy',
      'email': email,
      'name': name,
      'amount': amount,
      'callback_url': subscription_callback_url,
      'description': description
    };
    var response = await ApiClient.postData(bill_url,
        headers: <String, String>{'authorization': basicAuth},
        body: parameters);

    return response;
  }

  Future<dynamic> createSponsorBill(
      String email, String name, String amount, String description) async {
    Map<String, String> parameters = {
      'collection_id': 'c2kz8c4c',
      'email': email,
      'name': name,
      'amount': amount,
      'callback_url': sponsor_callback_url,
      'description': description,
    };
    var response = await ApiClient.postData(bill_url,
        headers: <String, String>{'authorization': basicAuth},
        body: parameters);

    return response;
  }

  Future<dynamic> createBill(
      String email, String name, String amount, String description) async {
    Map<String, String> parameters = {
      'collection_id': 'hqbfq0pq',
      'email': email,
      'name': name,
      'amount': amount,
      'description': description,
      'callback_url': 'http://'
    };
    var response = await ApiClient.postData(bill_url,
        headers: <String, String>{'authorization': basicAuth},
        body: parameters);

    return response;
  }
}
