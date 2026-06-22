import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task/providers/group_provider.dart';
import 'package:task/screens/groups/create_group_screen.dart';
import 'package:task/screens/groups/group_detail_screen.dart';
import 'package:task/widgets/group_card.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interest Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GroupProvider>().fetchGroups(),
          ),
        ],
      ),
      body: groupProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupProvider.groups.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No groups yet. Create one!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<GroupProvider>().fetchGroups(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: groupProvider.groups.length,
                    itemBuilder: (context, index) {
                      final group = groupProvider.groups[index];
                      return GroupCard(
                        group: group,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(group: group),
                            ),
                          ).then((_) {
                            if (context.mounted) {
                              context.read<GroupProvider>().fetchGroups();
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
