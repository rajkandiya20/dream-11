import 'package:flutter/material.dart';

/// Dialog shown after wicket or start of innings to select the next batsman
/// from the team's playing XI.
class SelectBatsmanDialog extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  final String title;
  final void Function(String playerId, String playerName) onPlayerSelected;

  const SelectBatsmanDialog({
    super.key,
    required this.players,
    required this.title,
    required this.onPlayerSelected,
  });

  /// Shows the dialog and returns the selected player info.
  static Future<void> show({
    required BuildContext context,
    required List<Map<String, dynamic>> players,
    required String title,
    required void Function(String playerId, String playerName) onSelected,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SelectBatsmanDialog(
        players: players,
        title: title,
        onPlayerSelected: (id, name) {
          Navigator.pop(ctx);
          onSelected(id, name);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          const Icon(
            Icons.sports_cricket,
            size: 20,
            color: Color(0xFFE91E63),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: players.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No players available',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: players.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final player = players[index];
                  final name = player['name'] as String? ?? 'Unknown';
                  final id = player['id'] as String? ?? '';
                  final role = player['role'] as String? ?? '';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(0xFFE91E63).withOpacity(0.1),
                      radius: 18,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Color(0xFFE91E63),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: role.isNotEmpty
                        ? Text(
                            role,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                        : null,
                    onTap: () => onPlayerSelected(id, name),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
