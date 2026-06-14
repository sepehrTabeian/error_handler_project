import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_request_entity.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentUserIdMissing) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('امکان پرداخت وجود ندارد'),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('متوجه شدم'),
                ),
              ],
            ),
          );
        }

        if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }

        if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'پرداخت با موفقیت انجام شد: ${state.payment.paymentId}',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('پرداخت'),
        ),
        body: Center(
          child: BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              if (state is PaymentLoading) {
                return const CircularProgressIndicator();
              }

              return ElevatedButton(
                onPressed: () {
                  const request = PaymentRequestEntity(
                    amount: 120000,
                    currency: 'IRR',
                  );

                  context.read<PaymentBloc>().add(
                    const PayRequested(request),
                  );
                },
                child: const Text('پرداخت'),
              );
            },
          ),
        ),
      ),
    );
  }
}