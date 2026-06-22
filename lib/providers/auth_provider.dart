// ============================================================
// auth_provider.dart — Authentication State Management
// ============================================================
// This provider handles all login/register/logout logic.
// Screens listen to this provider using context.watch<AuthProvider>()
// and call its methods using context.read<AuthProvider>().

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  // Supabase client — used to call auth functions
  final _client = Supabase.instance.client;

  bool _isLoading = false;    // true while a request is in progress
  String? _errorMessage;      // holds error text if something fails

  // Getters — screens read these values
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _client.auth.currentUser;

  // ── LOGIN ──────────────────────────────────────────────────
  // Returns true if login succeeded, false if it failed
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // tell all listening screens to rebuild

    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true; // success
    } on AuthException catch (e) {
      // Supabase auth errors (wrong password, user not found, etc.)
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Any other unexpected error
      _errorMessage = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── REGISTER ───────────────────────────────────────────────
  // Creates the auth user, then creates a profile row in the database
  Future<bool> signUp(String email, String password, String username) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Create the user account in Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      // If user creation failed, stop here
      if (response.user == null) {
        _errorMessage = 'Registration failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Step 2: Save the username in our profiles table
      // This might fail if email confirmation is required (RLS blocks it).
      // That's okay — it will be created when the user logs in.
      try {
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'username': username,
          'bio': '',
        });
      } catch (_) {
        // Profile insert failed — not a critical error
      }

      _isLoading = false;
      notifyListeners();
      return true; // registration success
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
    notifyListeners(); // AuthWrapper will redirect to LoginScreen
  }
}
