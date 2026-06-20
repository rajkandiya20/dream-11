import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/env.dart';

/// Provider for the Supabase client instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Helper class for Supabase operations including real-time subscriptions.
class SupabaseClientHelper {
  final SupabaseClient _client;

  SupabaseClientHelper(this._client);

  /// Get the Supabase client instance
  SupabaseClient get client => _client;

  /// Get the current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Get the current session
  Session? get currentSession => _client.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Initialize Supabase with environment configuration.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
    );
  }

  /// Query a table with optional filters.
  PostgrestFilterBuilder<List<Map<String, dynamic>>> from(String table) {
    return _client.from(table).select();
  }

  /// Insert data into a table.
  Future<List<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.from(table).insert(data).select();
    return response;
  }

  /// Update data in a table.
  Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required String matchColumn,
    required dynamic matchValue,
  }) async {
    final response = await _client
        .from(table)
        .update(data)
        .eq(matchColumn, matchValue)
        .select();
    return response;
  }

  /// Delete data from a table.
  Future<void> delete(
    String table, {
    required String matchColumn,
    required dynamic matchValue,
  }) async {
    await _client.from(table).delete().eq(matchColumn, matchValue);
  }

  /// Subscribe to real-time changes on a table.
  RealtimeChannel subscribeToTable(
    String table, {
    required void Function(PostgrestResponse) onInsert,
    void Function(PostgrestResponse)? onUpdate,
    void Function(PostgrestResponse)? onDelete,
    String? filter,
  }) {
    var channel = _client.channel('public:$table');

    channel = channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: table,
      filter: filter != null ? PostgresChangeFilter.fromString(filter) : null,
      callback: (payload) {
        onInsert(PostgrestResponse(
          data: payload.newRecord,
          count: 1,
        ));
      },
    );

    if (onUpdate != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        filter: filter != null ? PostgresChangeFilter.fromString(filter) : null,
        callback: (payload) {
          onUpdate(PostgrestResponse(
            data: payload.newRecord,
            count: 1,
          ));
        },
      );
    }

    if (onDelete != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: table,
        filter: filter != null ? PostgresChangeFilter.fromString(filter) : null,
        callback: (payload) {
          onDelete(PostgrestResponse(
            data: payload.oldRecord,
            count: 1,
          ));
        },
      );
    }

    channel.subscribe();
    return channel;
  }

  /// Unsubscribe from a real-time channel.
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  /// Remove all real-time subscriptions.
  Future<void> removeAllChannels() async {
    await _client.removeAllChannels();
  }
}

/// Response wrapper for Supabase Postgrest queries.
class PostgrestResponse {
  final dynamic data;
  final int? count;

  const PostgrestResponse({
    required this.data,
    this.count,
  });
}
