import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task/models/group_model.dart';
import 'package:task/providers/group_provider.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback? onTap;

  const GroupCard({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.read<GroupProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          child: Icon(Icons.group),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description.isNotEmpty)
              Text(
                group.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: group.isMember
            ? OutlinedButton(
                onPressed: () => groupProvider.leaveGroup(group.id),
                child: const Text('Leave'),
              )
            : FilledButton(
                onPressed: () => groupProvider.joinGroup(group.id),
                child: const Text('Join'),
              ),
        isThreeLine: group.description.isNotEmpty,
      ),
    );
  }
}
