part of 'payment_cubit.dart';

@immutable
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class CreatingSubscriptionBillState extends PaymentState {}

class SubscriptionBillCreatedState extends PaymentState {
  final BillModel bill;

  SubscriptionBillCreatedState(this.bill);
}
