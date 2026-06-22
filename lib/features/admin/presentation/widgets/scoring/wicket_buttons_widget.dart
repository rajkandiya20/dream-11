import 'package:flutter/material.dart';

/// Buttons for Bowled, Caught, LBW, Run Out, Stumped, Hit Wicket.
/// Each opens a callback that the parent screen handles for dialog flow.
class WicketButtonsWidget extends StatelessWidget {
  final void Function(String dismissalType) onWicketTapped;

  const WicketButtonsWidget({
    super.key,
    required this.onWicketTapped,
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
            'Wicket',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildWicketButton('Bowled', 'bowled'),
              _buildWicketButton('Caught', 'caught'),
              _buildWicketButton('LBW', 'lbw'),
              _buildWicketButton('Run Out', 'run_out'),
              _buildWicketButton('Stumped', 'stumped'),
              _buildWicketButton('Hit Wicket', 'hit_wicket'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWicketButton(String label, String type) {
    return GestureDetector(
      onTap: () => onWicketTapped(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF44336).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFF44336).withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF44336),
          ),
        ),
      ),
    );
  }
}
