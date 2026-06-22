import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task/models/group_model.dart';
import 'package:task/providers/group_provider.dart';

class GroupDetailScreen extends StatelessWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    // Get the latest version of this group from provider
    final currentGroup = groupProvider.groups.firstWhere(
      (g) => g.id == group.id,
      orElse: () => group,
    );

    return Scaffold(
      appBar: AppBar(title: Text(currentGroup.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          child: Icon(Icons.group, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentGroup.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${currentGroup.memberCount} member${currentGroup.memberCount == 1 ? '' : 's'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (currentGroup.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(currentGroup.description),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Join / Leave button
            SizedBox(
              width: double.infinity,
              child: currentGroup.isMember
                  ? OutlinedButton.icon(
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Leave Group'),
                      onPressed: () async {
                        await groupProvider.leaveGroup(currentGroup.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                    )
                  : FilledButton.icon(
                      icon: const Icon(Icons.group_add),
                      label: const Text('Join Group'),
                      onPressed: () async {
                        await groupProvider.joinGroup(currentGroup.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
