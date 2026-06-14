class PaymentEntity {
  final String paymentId;
  final String status;
  final double amount;

  const PaymentEntity({
    required this.paymentId,
    required this.status,
    required this.amount,
  });
}