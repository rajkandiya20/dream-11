import 'package:flutter/material.dart';

/// Group detail screen placeholder - full implementation in FEAT-004.
class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Group Detail: $groupId'),
      ),
    );
  }
}
