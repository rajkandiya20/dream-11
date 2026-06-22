import 'package:flutter/material.dart';

/// Buttons for Wide, No Ball, Bye, Leg Bye extras.
/// Wide and No Ball show a sub-dialog for additional runs.
class ExtrasButtonsWidget extends StatelessWidget {
  final void Function(String type, int additionalRuns) onExtraTapped;

  const ExtrasButtonsWidget({
    super.key,
    required this.onExtraTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extras',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildExtraButton(
                  context,
                  label: 'Wide',
                  color: const Color(0xFF2196F3),
                  type: 'wide',
                  showAdditionalRunsDialog: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExtraButton(
                  context,
                  label: 'No Ball',
                  color: const Color(0xFFFF9800),
                  type: 'no_ball',
                  showAdditionalRunsDialog: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExtraButton(
                  context,
                  label: 'Bye',
                  color: const Color(0xFF03A9F4),
                  type: 'bye',
                  showAdditionalRunsDialog: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExtraButton(
                  context,
                  label: 'Leg Bye',
                  color: const Color(0xFF03A9F4),
                  type: 'leg_bye',
                  showAdditionalRunsDialog: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtraButton(
    BuildContext context, {
    required String label,
    required Color color,
    required String type,
    required bool showAdditionalRunsDialog,
  }) {
    return GestureDetector(
      onTap: () {
        if (showAdditionalRunsDialog) {
          _showAdditionalRunsDialog(context, type, label, color);
        } else {
          onExtraTapped(type, 0);
        }
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showAdditionalRunsDialog(
    BuildContext context,
    String type,
    String label,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '$label + Additional Runs',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select additional runs scored:',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    onExtraTapped(type, i);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        '+$i',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
