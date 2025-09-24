import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => SupabaseConfig.client;
  
  // Auth methods
  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;
  
  // Sign in with email and password
  static Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // Sign up with email and password
  static Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }
  
  // Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }
  
  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // Database operations
  static PostgrestQueryBuilder from(String table) => client.from(table);
  
  // Storage operations
  static SupabaseStorageClient get storage => client.storage;
  
  // Real-time subscriptions
  static RealtimeChannel channel(String name) => client.channel(name);
}