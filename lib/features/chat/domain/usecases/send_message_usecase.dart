import 'package:error_handler_project/features/chat/domain/entities/send_message_request_entity.dart';
import 'package:error_handler_project/features/chat/domain/repositories/chat_repository.dart';
import 'package:error_handler_project/infrastructure/errors/app_failure.dart';
import 'package:error_handler_project/infrastructure/errors/result.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Result<void>> call(String text) {
    if (text.trim().isEmpty) {
      return Future.value(
        const FailureResult(
          ValidationFailure(message: 'متن پیام نمی‌تواند خالی باشد'),
        ),
      );
    }

    return repository.sendMessage(
      SendMessageRequestEntity(text: text.trim()),
    );
  }
}