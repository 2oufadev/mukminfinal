import 'package:mukim_app/data/api/payment_api.dart';
import 'package:mukim_app/data/models/bill_model.dart';

class PaymentRepository {
  final PaymentApi _paymentApi;

  PaymentRepository(this._paymentApi);

  Future<BillModel?> createBill(String email, String name, String amount,
      String description, int mode) async {
    if (mode == 0) {
      var response = await _paymentApi.createSubscriptionBill(
          email, name, amount, description);

      if (response['status'] == true) {
        return BillModel.fromJson(response['data']);
      } else {
        return null;
      }
    } else if (mode == 1) {
      var response =
          await _paymentApi.createSponsorBill(email, name, amount, description);

      if (response['status'] == true) {
        return BillModel.fromJson(response['data']);
      } else {
        return null;
      }
    } else {
      var response =
          await _paymentApi.createBill(email, name, amount, description);

      if (response['status'] == true) {
        return BillModel.fromJson(response['data']);
      } else {
        return null;
      }
    }
  }
}
