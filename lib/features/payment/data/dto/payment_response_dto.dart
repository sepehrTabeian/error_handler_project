import '../../domain/entities/payment_entity.dart';

class PaymentResponseDto {
  final String paymentId;
  final String status;
  final double amount;

  const PaymentResponseDto({
    required this.paymentId,
    required this.status,
    required this.amount,
  });

  factory PaymentResponseDto.fromJson(Map<String, dynamic> json) {
    return PaymentResponseDto(
      paymentId: json['payment_id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      paymentId: paymentId,
      status: status,
      amount: amount,
    );
  }
}