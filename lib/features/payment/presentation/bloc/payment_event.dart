import '../../domain/entities/payment_request_entity.dart';

sealed class PaymentEvent {
  const PaymentEvent();
}

class PayRequested extends PaymentEvent {
  final PaymentRequestEntity request;

  const PayRequested(this.request);
}