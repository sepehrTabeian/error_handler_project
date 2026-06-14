import 'package:dio/dio.dart';
import 'package:error_handler_project/features/chat/data/dto/chat_message_dto.dart';
import 'package:error_handler_project/features/chat/data/dto/send_message_dto.dart';
import 'package:error_handler_project/infrastructure/errors/dio_error_mapper.dart';

abstract class ChatRemoteDataSource {
  Future<ChatMessageDto> sendMessage(SendMessageDto request);
}
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;
  final DioErrorMapper errorMapper;

  ChatRemoteDataSourceImpl({
    required this.dio,
    required this.errorMapper,
  });

  @override
  Future<ChatMessageDto> sendMessage(SendMessageDto request) async {
    try {
      final response = await dio.post(
        '/chat/messages',
        data: request.toJson(),
      );

      return ChatMessageDto.fromJson(response.data);
    } catch (error) {
      throw errorMapper.map(error);
    }
  }
}