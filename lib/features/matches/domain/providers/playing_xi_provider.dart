import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client.dart';

/// Fetches the list of player IDs in the Playing XI for a match.
/// Returns a Set<String> of player IDs that are confirmed playing.
/// Empty set = lineup not announced yet.
final playingXIProvider =
    FutureProvider.family<Set<String>, String>((ref, matchId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client
        .from('match_players')
        .select('player_id')
        .eq('match_id', matchId);
    final ids = (response as List)
        .map((r) => r['player_id'] as String)
        .toSet();
    return ids;
  } catch (_) {
    return {};
  }
});
