import 'package:flutter/material.dart';

/// Create team screen placeholder - full implementation in FEAT-004.
class CreateTeamScreen extends StatelessWidget {
  final String matchId;

  const CreateTeamScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Create Team for Match: $matchId'),
      ),
    );
  }
}
