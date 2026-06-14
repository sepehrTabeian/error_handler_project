// lib/features/chat/data/datasources/drift_chat_local_datasource.dart

import 'package:drift/drift.dart';

import '../../../../infrastructure/database/app_database.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../dto/chat_message_dto.dart';
import 'chat_local_datasource.dart';

class DriftChatLocalDataSource implements ChatLocalDataSource {
  final AppDatabase database;

  DriftChatLocalDataSource(this.database);

  @override
  Stream<List<ChatMessageDto>> watchMessages() {
    final query = database.select(database.chatMessages)
      ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
      ]);

    return query.watch().map(
          (rows) => rows.map(_rowToDto).toList(),
    );
  }

  @override
  Future<void> saveMessage(ChatMessageDto message) async {
    await database.into(database.chatMessages).insert(
      _dtoToCompanion(message),
      mode: InsertMode.insertOrReplace,
    );
  }

  @override
  Future<void> updateMessage(ChatMessageDto message) async {
    await database.update(database.chatMessages).replace(
      _dtoToCompanion(message),
    );
  }

  @override
  Future<List<ChatMessageDto>> getPendingMessages() async {
    final query = database.select(database.chatMessages)
      ..where(
            (table) => table.status.equals(
          MessageSendStatus.pending.name,
        ),
      )
      ..orderBy([
            (table) => OrderingTerm.asc(table.createdAt),
      ]);

    final rows = await query.get();

    return rows.map(_rowToDto).toList();
  }

  @override
  Future<List<ChatMessageDto>> getFailedMessages() async {
    final query = database.select(database.chatMessages)
      ..where(
            (table) => table.status.equals(
          MessageSendStatus.failed.name,
        ),
      )
      ..orderBy([
            (table) => OrderingTerm.asc(table.createdAt),
      ]);

    final rows = await query.get();

    return rows.map(_rowToDto).toList();
  }

  @override
  Future<void> markAsPending(String localId) async {
    await (database.update(database.chatMessages)
      ..where(
            (table) => table.localId.equals(localId),
      ))
        .write(
      ChatMessagesCompanion(
        status: Value(MessageSendStatus.pending.name),
      ),
    );
  }

  @override
  Future<void> deleteMessage(String localId) async {
    await (database.delete(database.chatMessages)
      ..where(
            (table) => table.localId.equals(localId),
      ))
        .go();
  }

  ChatMessageDto _rowToDto(ChatMessage row) {
    return ChatMessageDto(
      localId: row.localId,
      serverId: row.serverId,
      userId: row.userId,
      text: row.messageText,
      createdAt: row.createdAt,
      status: _statusFromString(row.status),
    );
  }

  ChatMessagesCompanion _dtoToCompanion(ChatMessageDto dto) {
    return ChatMessagesCompanion(
      localId: Value(dto.localId),
      serverId: Value(dto.serverId),
      userId: Value(dto.userId),
      messageText: Value(dto.text),
      createdAt: Value(dto.createdAt),
      status: Value(dto.status.name),
    );
  }

  MessageSendStatus _statusFromString(String value) {
    return MessageSendStatus.values.firstWhere(
          (status) => status.name == value,
      orElse: () => MessageSendStatus.failed,
    );
  }
}