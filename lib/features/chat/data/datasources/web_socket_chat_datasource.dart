import 'dart:async';
import 'dart:convert';

import 'package:error_handler_project/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:error_handler_project/features/chat/data/dto/chat_message_dto.dart';
import 'package:error_handler_project/features/chat/data/dto/send_message_dto.dart';
import 'package:error_handler_project/infrastructure/auth/token_provider.dart';
import 'package:error_handler_project/infrastructure/errors/app_exception.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


/// WebSocket-based implementation of [ChatSocketDataSource].
///
/// Responsibilities:
/// - Establish a real-time connection with the chat server.
/// - Send outgoing chat messages.
/// - Listen for incoming chat events.
/// - Convert raw socket payloads into DTOs used by the data layer.
///
/// This class is intentionally not responsible for updating the local
/// database. Incoming messages should be handled by the repository and then
/// persisted into the local data source so the database remains the single
/// source of truth.
class WebSocketChatDataSource implements ChatSocketDataSource {
  final TokenProvider tokenProvider;
  final String socketUrl;

  /// Active websocket connection.
  ///
  /// Null means the socket has not been connected yet or has already been
  /// disconnected.
  WebSocketChannel? _channel;
  /// Broadcast stream used to emit incoming chat messages.
  ///
  /// A broadcast stream allows multiple listeners (repository, debugging tools,
  /// tests, etc.) to observe incoming events simultaneously.
  final StreamController<ChatMessageDto> _incomingController =
  StreamController<ChatMessageDto>.broadcast();

  WebSocketChatDataSource({
    required this.tokenProvider,
    required this.socketUrl,
  });

  @override
  /// Exposes incoming socket messages as a stream.
  ///
  /// Consumers subscribe to this stream to receive real-time messages from the
  /// server.
  Stream<ChatMessageDto> watchIncomingMessages() {
    return _incomingController.stream;
  }

  @override
  /// Opens the websocket connection.
  ///
  /// The access token is attached as a query parameter so the backend can
  /// authenticate the user before allowing chat communication.
  ///
  /// After a successful connection, socket events are decoded and translated
  /// into strongly typed DTOs.
  Future<void> connect() async {
    final token = await tokenProvider.getAccessToken();

    final uri = Uri.parse(socketUrl).replace(
      queryParameters: {
        'token': token,
      }..removeWhere((key, value) => value == null),
    );

    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
          (raw) {
        final decoded = jsonDecode(raw as String);

        if (decoded is! Map<String, dynamic>) {
          return;
        }

        final type = decoded['type'];

        /// New message created on the server.
        ///
        /// The payload is converted into a DTO and emitted through the incoming
        /// message stream.
        if (type == 'message.created') {
          final payload = decoded['payload'];

          if (payload is Map<String, dynamic>) {
            _incomingController.add(
              ChatMessageDto.fromJson(payload),
            );
          }
        }
      },
      onError: (_) {
        // later: emit socket status / reconnect
      },
      onDone: () {
        // later: reconnect strategy
      },
    );
  }

  @override
  /// Sends a chat message through the active websocket connection.
  ///
  /// Throws [NetworkException] when no socket connection is currently active.
  Future<void> sendMessage(SendMessageDto request) async {
    final channel = _channel;

    if (channel == null) {
      throw const NetworkException();
    }

    channel.sink.add(
      jsonEncode({
        'type': 'message.send',
        'payload': request.toJson(),
      }),
    );
  }

  @override
  /// Closes the websocket connection and releases resources.
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }
}