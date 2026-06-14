import '../../domain/entities/payment_entity.dart';

sealed class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentSuccess extends PaymentState {
  final PaymentEntity payment;

  const PaymentSuccess(this.payment);
}

class PaymentUserIdMissing extends PaymentState {
  final String message;

  const PaymentUserIdMissing(this.message);
}

class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure(this.message);
}