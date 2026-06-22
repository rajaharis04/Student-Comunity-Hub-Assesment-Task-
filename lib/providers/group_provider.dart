// ============================================================
// group_provider.dart — Interest Groups State Management
// ============================================================
// Handles fetching groups, creating groups, joining and leaving.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task/models/group_model.dart';

class GroupProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;

  List<Group> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── FETCH ALL GROUPS ───────────────────────────────────────
  // Also checks which groups the current user has joined
  Future<void> fetchGroups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser?.id;

      // Get all groups from database
      final groupsData = await _client
          .from('groups')
          .select()
          .order('created_at', ascending: false);

      // Get list of group IDs that the current user has joined
      List memberGroupIds = [];
      if (userId != null) {
        final memberData = await _client
            .from('group_members')
            .select('group_id')
            .eq('user_id', userId);
        memberGroupIds = (memberData as List)
            .map((row) => row['group_id'])
            .toList();
      }

      // Build the final list with member count and isMember flag
      final List<Group> loaded = [];
      for (final row in (groupsData as List)) {
        final group = Group.fromMap(row);

        // Mark if current user is already a member
        group.isMember = memberGroupIds.contains(group.id);

        // Count total members in this group
        final countResult = await _client
            .from('group_members')
            .select('id')
            .eq('group_id', group.id)
            .count(CountOption.exact);
        group.memberCount = countResult.count;

        loaded.add(group);
      }

      _groups = loaded;
    } catch (e) {
      _errorMessage = 'Failed to load groups.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── CREATE GROUP ───────────────────────────────────────────
  Future<bool> createGroup(String name, String description) async {
    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('groups').insert({
        'name': name,
        'description': description,
        'creator_id': userId,
      });
      await fetchGroups(); // refresh list
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create group.';
      notifyListeners();
      return false;
    }
  }

  // ── JOIN GROUP ─────────────────────────────────────────────
  Future<void> joinGroup(String groupId) async {
    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
      });
      await fetchGroups(); // refresh to update isMember and memberCount
    } catch (e) {
      _errorMessage = 'Failed to join group.';
      notifyListeners();
    }
  }

  // ── LEAVE GROUP ────────────────────────────────────────────
  Future<void> leaveGroup(String groupId) async {
    try {
      final userId = _client.auth.currentUser!.id;
      await _client
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
      await fetchGroups(); // refresh
    } catch (e) {
      _errorMessage = 'Failed to leave group.';
      notifyListeners();
    }
  }
}
