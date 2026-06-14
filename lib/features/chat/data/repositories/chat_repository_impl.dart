import 'dart:async';

import 'package:error_handler_project/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:error_handler_project/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:error_handler_project/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:error_handler_project/features/chat/data/dto/chat_message_dto.dart';
import 'package:error_handler_project/features/chat/data/dto/send_message_dto.dart';
import 'package:error_handler_project/features/chat/domain/entities/chat_message_entity.dart';
import 'package:error_handler_project/features/chat/domain/entities/send_message_request_entity.dart';
import 'package:error_handler_project/features/chat/domain/repositories/chat_repository.dart';
import 'package:error_handler_project/infrastructure/errors/app_failure.dart';
import 'package:error_handler_project/infrastructure/errors/app_failure_mapper.dart';
import 'package:error_handler_project/infrastructure/errors/result.dart';
import 'package:error_handler_project/infrastructure/session/user_context_service.dart';

/// Offline-first implementation of [ChatRepository].
///
/// The local database is the single source of truth for the chat UI. Both REST
/// and WebSocket are only synchronization mechanisms. Any message received from
/// the server or successfully synced must be written to the local data source;
/// the UI will then update through [watchMessages].
class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;
  final ChatRemoteDataSource remoteDataSource;
  final ChatSocketDataSource socketDataSource;
  final UserContextService userContextService;
  final FailureMapper failureMapper;

  /// Subscription to incoming messages received from the realtime socket.
  ///
  /// Incoming socket messages are saved into the local database instead of
  /// being emitted directly to the UI. This keeps the offline-first flow
  /// consistent and prevents the UI from depending on the socket layer.
  StreamSubscription<ChatMessageDto>? _socketSubscription;

  ChatRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.socketDataSource,
    required this.userContextService,
    required this.failureMapper,
  });

  /// Watches messages from the local database.
  ///
  /// This returns a stream because the UI must react automatically whenever the
  /// local database changes: pending insert, sent update, failed update, retry,
  /// or incoming socket message.
  @override
  Stream<List<ChatMessageEntity>> watchMessages() {
    return localDataSource.watchMessages().map(
          (messages) => messages.map((e) => e.toEntity()).toList(),
    );
  }

  /// Connects the realtime socket and persists incoming messages locally.
  ///
  /// Socket messages do not bypass the local database. Each incoming message is
  /// saved locally with [MessageSendStatus.sent], which triggers
  /// [watchMessages] and updates the UI.
  @override
  Future<Result<void>> connectRealtime() async {
    try {
      await socketDataSource.connect();

      await _socketSubscription?.cancel();

      _socketSubscription =
          socketDataSource.watchIncomingMessages().listen(
                (message) async {
              await localDataSource.saveMessage(
                message.copyWith(
                  status: MessageSendStatus.sent,
                ),
              );
            },
          );

      return const Success(null);
    } catch (error) {
      return FailureResult(failureMapper.map(error));
    }
  }

  /// Disconnects the realtime socket and cancels its message subscription.
  @override
  Future<void> disconnectRealtime() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await socketDataSource.disconnect();
  }

  /// Sends a chat message using an offline-first flow.
  ///
  /// The message is saved locally first with [MessageSendStatus.pending], so it
  /// appears immediately in the UI. The repository then tries WebSocket first.
  /// If WebSocket is unavailable, it falls back to REST. If all remote attempts
  /// fail, the local message is marked as [MessageSendStatus.failed] so it can
  /// be retried later by [syncPendingMessages].
  @override
  Future<Result<void>> sendMessage(
      SendMessageRequestEntity request,
      ) async {
    final userId = userContextService.userId;

    if (userId == null || userId.isEmpty) {
      return const FailureResult(UserIdRequiredFailure());
    }

    final now = DateTime.now();

    final localMessage = ChatMessageDto(
      localId: now.microsecondsSinceEpoch.toString(),
      serverId: null,
      userId: userId,
      text: request.text,
      createdAt: now,
      status: MessageSendStatus.pending,
    );

    await localDataSource.saveMessage(localMessage);

    final sendDto = SendMessageDto(
      localId: localMessage.localId,
      userId: userId,
      text: request.text,
      createdAt: now.toIso8601String(),
    );

    try {
      await socketDataSource.sendMessage(sendDto);

      return const Success(null);
    } catch (_) {
      return _sendMessageViaRestFallback(
        localMessage: localMessage,
        sendDto: sendDto,
      );
    }
  }

  /// Sends a previously locally persisted message through REST as a fallback.
  ///
  /// This method is used when WebSocket sending fails or when pending/failed
  /// messages are retried later. It updates the existing local row instead of
  /// creating a new local message, preventing duplicates.
  Future<Result<void>> _sendMessageViaRestFallback({
    required ChatMessageDto localMessage,
    required SendMessageDto sendDto,
  }) async {
    try {
      final serverMessage = await remoteDataSource.sendMessage(sendDto);

      await localDataSource.updateMessage(
        localMessage.copyWith(
          serverId: serverMessage.serverId,
          status: MessageSendStatus.sent,
        ),
      );

      return const Success(null);
    } catch (error) {
      await localDataSource.updateMessage(
        localMessage.copyWith(
          status: MessageSendStatus.failed,
        ),
      );

      return FailureResult(failureMapper.map(error));
    }
  }

  /// Retries messages that were not successfully synced before.
  ///
  /// This method is required in an offline-first chat because messages may stay
  /// in the local database with `pending` or `failed` status when the app was
  /// offline, the socket was disconnected, or the REST fallback failed.
  ///
  /// Typical trigger points:
  /// - app startup,
  /// - opening the chat screen,
  /// - connectivity restored,
  /// - manual retry button.
  ///
  /// The method reads pending and failed messages from the local database,
  /// marks each one as pending while retrying, sends it through REST, and then
  /// updates the same local row to `sent` or `failed`.
  @override
  Future<Result<void>> syncPendingMessages() async {
    final userId = userContextService.userId;

    if (userId == null || userId.isEmpty) {
      return const FailureResult(UserIdRequiredFailure());
    }

    try {
      final pendingMessages = await localDataSource.getPendingMessages();
      final failedMessages = await localDataSource.getFailedMessages();

      final messagesToSync = <ChatMessageDto>[
        ...pendingMessages,
        ...failedMessages,
      ];

      for (final message in messagesToSync) {
        await localDataSource.markAsPending(message.localId);

        final sendDto = SendMessageDto(
          localId: message.localId,
          userId: message.userId,
          text: message.text,
          createdAt: message.createdAt.toIso8601String(),
        );

        final result = await _sendMessageViaRestFallback(
          localMessage: message.copyWith(
            status: MessageSendStatus.pending,
          ),
          sendDto: sendDto,
        );

        if (result is FailureResult<void>) {
          return result;
        }
      }

      return const Success(null);
    } catch (error) {
      return FailureResult(failureMapper.map(error));
    }
  }
}