import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cached_image.dart';

final _searchResultsProvider =
    FutureProvider.family<List<_UserResult>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final client = ref.watch(supabaseClientProvider);
  try {
    final res = await client
        .from('users')
        .select('id, username, avatar_url, matches_played, contests_won')
        .ilike('username', '%$query%')
        .limit(30);
    return (res as List)
        .map((j) => _UserResult.fromJson(j as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

class _UserResult {
  final String id;
  final String username;
  final String? avatarUrl;
  final int matchesPlayed;
  final int contestsWon;

  const _UserResult({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.matchesPlayed,
    required this.contestsWon,
  });

  factory _UserResult.fromJson(Map<String, dynamic> j) => _UserResult(
        id:            j['id'] as String? ?? '',
        username:      j['username'] as String? ?? 'User',
        avatarUrl:     j['avatar_url'] as String?,
        matchesPlayed: j['matches_played'] as int? ?? 0,
        contestsWon:   j['contests_won']   as int? ?? 0,
      );
}

/// Find People screen — search other users by username.
/// Ported from Fantasy- findPeople/FindPeople.js.
class FindPeopleScreen extends ConsumerStatefulWidget {
  const FindPeopleScreen({super.key});

  @override
  ConsumerState<FindPeopleScreen> createState() => _FindPeopleScreenState();
}

class _FindPeopleScreenState extends ConsumerState<FindPeopleScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Find People',
            style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search people you know…',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide:
                      BorderSide(color: AppColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  borderSide:
                      BorderSide(color: AppColors.border, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Results
          Expanded(
            child: _query.trim().length < 2
                ? _buildHint()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.textTertiary),
          AppSpacing.gapH16,
          Text('Search for players by username',
              style: AppTypography.bodyLarge
                  .copyWith(color: AppColors.textSecondary)),
          AppSpacing.gapH8,
          Text('Enter at least 2 characters',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final resultsAsync = ref.watch(_searchResultsProvider(_query));
    return resultsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => Center(
          child: Text('Search failed',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary))),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 64, color: AppColors.textTertiary),
                AppSpacing.gapH16,
                Text('No users found for "$_query"',
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: results.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          itemBuilder: (_, i) => _UserTile(user: results[i]),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final _UserResult user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          user.avatarUrl != null
              ? CachedImage.avatar(imageUrl: user.avatarUrl, size: 44)
              : Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                      style: AppTypography.titleSmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
          AppSpacing.gapW12,
          // Name + stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username,
                    style: AppTypography.titleSmall
                        .copyWith(fontWeight: FontWeight.w600)),
                AppSpacing.gapH4,
                Row(
                  children: [
                    Icon(Icons.sports_cricket_outlined,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text('${user.matchesPlayed} matches',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textTertiary)),
                    AppSpacing.gapW8,
                    Icon(Icons.emoji_events_outlined,
                        size: 12, color: AppColors.warning),
                    const SizedBox(width: 3),
                    Text('${user.contestsWon} wins',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          // Follow button (placeholder)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusFull),
            ),
            onPressed: () {},
            child: Text('Follow',
                style:
                    AppTypography.labelSmall.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
