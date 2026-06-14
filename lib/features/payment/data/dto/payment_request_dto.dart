import '../../domain/entities/payment_request_entity.dart';

class PaymentRequestDto {
  final double amount;
  final String currency;
  final String userId;

  const PaymentRequestDto({
    required this.amount,
    required this.currency,
    required this.userId,
  });

  factory PaymentRequestDto.fromEntity(PaymentRequestEntity entity) {
    if (entity.userId == null || entity.userId!.isEmpty) {
      throw ArgumentError('userId is required for payment request');
    }

    return PaymentRequestDto(
      amount: entity.amount,
      currency: entity.currency,
      userId: entity.userId!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'user_id': userId,
    };
  }
}