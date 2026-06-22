// ============================================================
// main.dart — App Entry Point
// ============================================================
// This is the first file that runs when the app starts.
// It does 3 things:
//   1. Connects to Supabase (our backend/database)
//   2. Sets up all Providers (state management)
//   3. Decides whether to show Login or Home screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:task/core/supabase_config.dart';
import 'package:task/providers/auth_provider.dart';
import 'package:task/providers/group_provider.dart';
import 'package:task/providers/post_provider.dart';
import 'package:task/providers/profile_provider.dart';
import 'package:task/screens/auth/login_screen.dart';
import 'package:task/screens/home_screen.dart';

// main() runs first — must be async because Supabase.initialize() is async
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // required before any async work

  // Connect to Supabase using our URL and API key
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

// Root widget of the entire app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Register all providers so any screen can access them
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Student Community Hub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1D6B5F), // deep teal-green
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(), // decides login vs home
      ),
    );
  }
}

// AuthWrapper — checks if user is already logged in
// If logged in  → show HomeScreen
// If not logged in → show LoginScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to auth state changes in real-time
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Still loading auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if there is an active login session
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const HomeScreen(); // user is logged in
        }

        return const LoginScreen(); // user is not logged in
      },
    );
  }
}
