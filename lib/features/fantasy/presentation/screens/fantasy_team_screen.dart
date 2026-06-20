import 'package:flutter/material.dart';

/// Fantasy team view screen placeholder - full implementation in FEAT-004.
class FantasyTeamScreen extends StatelessWidget {
  final String teamId;

  const FantasyTeamScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Fantasy Team: $teamId'),
      ),
    );
  }
}
