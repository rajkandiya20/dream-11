import 'package:flutter/material.dart';

/// Match detail screen placeholder - full implementation in FEAT-003.
class MatchDetailScreen extends StatelessWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Match Detail: $matchId'),
      ),
    );
  }
}
