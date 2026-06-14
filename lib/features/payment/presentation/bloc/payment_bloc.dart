import 'package:error_handler_project/features/payment/domain/pay_usecase.dart';
import 'package:error_handler_project/infrastructure/errors/app_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../infrastructure/errors/result.dart';
import '../../domain/entities/payment_entity.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PayUseCase payUseCase;

  PaymentBloc({
    required this.payUseCase,
  }) : super(const PaymentInitial()) {
    on<PayRequested>(_onPayRequested);
  }

  Future<void> _onPayRequested(
      PayRequested event,
      Emitter<PaymentState> emit,
      ) async {
    emit(const PaymentLoading());

    final result = await payUseCase(event.request);

    switch (result) {
      case Success<PaymentEntity>():
        emit(PaymentSuccess(result.data));

      case FailureResult<PaymentEntity>():
        final failure = result.failure;

        if (failure is UserIdRequiredFailure) {
          emit(PaymentUserIdMissing(failure.message));
          return;
        }

        emit(PaymentFailure(failure.message));
    }
  }
}