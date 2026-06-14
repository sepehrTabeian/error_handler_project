// lib/infrastructure/database/app_database.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// =======================
/// Tables
/// =======================

class ChatMessages extends Table {
  TextColumn get localId => text()();

  TextColumn get serverId => text().nullable()();

  TextColumn get userId => text()();

  TextColumn get messageText =>
      text().named('message_text')();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get status => text()();

  @override
  Set<Column<Object>> get primaryKey => {localId};
}

/// =======================
/// Database
/// =======================

@DriftDatabase(
  tables: [
    ChatMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Migration
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },

      onUpgrade: (
          Migrator migrator,
          int from,
          int to,
          ) async {
        // future migrations
      },
    );
  }
}

/// =======================
/// Connection
/// =======================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDirectory =
    await getApplicationDocumentsDirectory();

    final file = File(
      p.join(
        documentsDirectory.path,
        'app_database.sqlite',
      ),
    );

    return NativeDatabase(file);
  });
}