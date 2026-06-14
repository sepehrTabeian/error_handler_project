class PaymentRequestEntity {
  final double amount;
  final String currency;
  final String? userId;

  const PaymentRequestEntity({
    required this.amount,
    required this.currency,
    this.userId,
  });

  PaymentRequestEntity copyWith({
    double? amount,
    String? currency,
    String? userId,
  }) {
    return PaymentRequestEntity(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      userId: userId ?? this.userId,
    );
  }
}