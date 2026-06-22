// ============================================================
// profile_provider.dart — User Profile State Management
// ============================================================
// Handles loading and updating the current user's profile
// (username and bio stored in the 'profiles' table in Supabase).

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task/models/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;

  Profile? _profile;          // null if not loaded yet
  bool _isLoading = false;
  String? _errorMessage;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── FETCH PROFILE ──────────────────────────────────────────
  // Loads the current user's profile row from Supabase
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return; // not logged in

      // .single() returns one row (throws if no row found)
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _profile = Profile.fromMap(data);
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── UPDATE PROFILE ─────────────────────────────────────────
  // Saves new username and bio to Supabase
  Future<bool> updateProfile(String username, String bio) async {
    try {
      final userId = _client.auth.currentUser!.id;

      await _client.from('profiles').update({
        'username': username,
        'bio': bio,
      }).eq('id', userId);

      // Update local profile immediately (no need to re-fetch)
      _profile = Profile(id: userId, username: username, bio: bio);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      notifyListeners();
      return false;
    }
  }

  // ── CLEAR PROFILE ──────────────────────────────────────────
  // Called on logout to reset the profile state
  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
