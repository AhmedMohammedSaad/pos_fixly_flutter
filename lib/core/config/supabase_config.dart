import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://mtxmzitasqtuukdhipav.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10eG16aXRhc3F0dXVrZGhpcGF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwMDI0NjksImV4cCI6MjA3MjU3ODQ2OX0.2cBXwkbv5-BizATym0ubpN3_Df5nYp71eP_NJHQ81Lw';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }
}