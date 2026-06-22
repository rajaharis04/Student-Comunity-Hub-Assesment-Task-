// ============================================================
// post_provider.dart — Anonymous Feed State Management
// ============================================================
// Handles fetching and creating anonymous posts.
// Posts have NO user_id — they are fully anonymous.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task/models/post_model.dart';

class PostProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;

  List<Post> _posts = [];   // list of all posts
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── FETCH ALL POSTS ────────────────────────────────────────
  // Loads posts from Supabase, newest first
  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _client
          .from('posts')
          .select()
          .order('created_at', ascending: false); // newest first

      // Convert each row (Map) into a Post object
      _posts = (response as List).map((row) => Post.fromMap(row)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load posts.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── CREATE A NEW POST ──────────────────────────────────────
  // Inserts a post into Supabase — no user_id (anonymous)
  Future<bool> createPost(String content) async {
    try {
      await _client.from('posts').insert({'content': content});
      await fetchPosts(); // refresh the list after posting
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create post.';
      notifyListeners();
      return false;
    }
  }
}
