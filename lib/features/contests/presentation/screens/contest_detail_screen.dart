import 'package:flutter/material.dart';

/// Contest detail screen placeholder - full implementation in FEAT-003.
class ContestDetailScreen extends StatelessWidget {
  final String contestId;

  const ContestDetailScreen({super.key, required this.contestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Contest Detail: $contestId'),
      ),
    );
  }
}
