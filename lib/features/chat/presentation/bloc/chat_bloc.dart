import 'dart:async';

import 'package:error_handler_project/features/chat/domain/entities/chat_message_entity.dart';
import 'package:error_handler_project/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:error_handler_project/features/chat/domain/usecases/sync_pending_messages_usecase.dart';
import 'package:error_handler_project/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:error_handler_project/features/chat/presentation/bloc/chat_event.dart';
import 'package:error_handler_project/features/chat/presentation/bloc/chat_state.dart';
import 'package:error_handler_project/infrastructure/errors/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Coordinates the offline-first chat presentation flow.
///
/// The UI does not fetch messages directly from the remote API. Instead, this
/// Bloc subscribes to the local database through [WatchMessagesUseCase]. Every
/// local database change is converted into a [ChatMessagesChanged] event and
/// then emitted as a new [ChatState].
///
/// This keeps the UI reactive to local changes such as pending messages,
/// successful sync updates, failed sends, and manual retry attempts.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final WatchMessagesUseCase watchMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final SyncPendingMessagesUseCase syncPendingMessagesUseCase;

  /// Active subscription to the local message stream.
  ///
  /// It must be cancelled when the Bloc is closed to avoid memory leaks and
  /// duplicate listeners when the chat screen is recreated.
  StreamSubscription<List<ChatMessageEntity>>? _messagesSubscription;

  ChatBloc({
    required this.watchMessagesUseCase,
    required this.sendMessageUseCase,
    required this.syncPendingMessagesUseCase,
  }) : super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatMessagesChanged>(_onMessagesChanged);
    on<ChatMessageSubmitted>(_onMessageSubmitted);
    on<ChatPendingSyncRequested>(_onPendingSyncRequested);
  }

  /// Starts listening to local chat messages.
  ///
  /// This is usually called when the chat screen is opened. It subscribes to
  /// [watchMessagesUseCase], so any insert/update/delete in the local database
  /// automatically reaches this Bloc.
  ///
  /// After the subscription is created, pending messages are synced once. This
  /// is useful when the app starts after being offline or when the user returns
  /// to the chat screen.
  Future<void> _onStarted(
      ChatStarted event,
      Emitter<ChatState> emit,
      ) async {
    await _messagesSubscription?.cancel();

    _messagesSubscription = watchMessagesUseCase().listen(
          (messages) {
        add(ChatMessagesChanged(messages));
      },
    );

    add(const ChatPendingSyncRequested());
  }

  /// Handles message updates coming from the local database stream.
  ///
  /// This handler is used internally after [watchMessagesUseCase] emits a new
  /// list of messages. It should not normally be triggered directly by the UI.
  ///
  /// Typical cases that trigger this handler:
  /// - a new message is saved locally as `pending`,
  /// - a pending message is updated to `sent` after successful sync,
  /// - a pending message is updated to `failed` after a network error,
  /// - failed or pending messages are retried and updated later.
  ///
  /// In other words, this is the bridge between the local database stream and
  /// the immutable [ChatState] used by the UI.
  void _onMessagesChanged(
      ChatMessagesChanged event,
      Emitter<ChatState> emit,
      ) {
    emit(
      state.copyWith(
        messages: event.messages,
        errorMessage: null,
      ),
    );
  }

  /// Handles a user-submitted message.
  ///
  /// The actual offline-first logic is delegated to [sendMessageUseCase]. That
  /// use case saves the message locally first, then tries to sync it with the
  /// server. The UI will receive the local message update through
  /// [_onMessagesChanged], not from this method directly.
  Future<void> _onMessageSubmitted(
      ChatMessageSubmitted event,
      Emitter<ChatState> emit,
      ) async {
    emit(state.copyWith(isSending: true, errorMessage: null));

    final result = await sendMessageUseCase(event.text);

    switch (result) {
      case Success<void>():
        emit(state.copyWith(isSending: false));

      case FailureResult<void>():
        emit(
          state.copyWith(
            isSending: false,
            errorMessage: result.failure.message,
          ),
        );
    }
  }

  /// Attempts to sync pending or failed local messages.
  ///
  /// This can be called on chat startup, manual retry, or after connectivity is
  /// restored. Successful sync updates the local database, and those updates are
  /// then propagated back to the UI through [_onMessagesChanged].
  Future<void> _onPendingSyncRequested(
      ChatPendingSyncRequested event,
      Emitter<ChatState> emit,
      ) async {
    final result = await syncPendingMessagesUseCase();

    switch (result) {
      case Success<void>():
        break;

      case FailureResult<void>():
        emit(
          state.copyWith(
            errorMessage: result.failure.message,
          ),
        );
    }
  }

  /// Cancels the local database subscription before closing the Bloc.
  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}