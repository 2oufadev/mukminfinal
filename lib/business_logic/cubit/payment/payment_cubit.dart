import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mukim_app/data/models/bill_model.dart';
import 'package:mukim_app/data/repository/payment_repository.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository paymentRepository;
  BillModel? subscriptionBill;
  PaymentCubit(this.paymentRepository) : super(PaymentInitial());

  BillModel createBill(
      String email, String name, String amount, String description, int mode) {
    emit(CreatingSubscriptionBillState());
    paymentRepository
        .createBill(email, name, amount, description, mode)
        .then((bill) {
      subscriptionBill = bill;
      emit(SubscriptionBillCreatedState(bill!));
    });

    return subscriptionBill!;
  }
}
