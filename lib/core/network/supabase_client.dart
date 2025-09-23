import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_constants.dart';

class AppSupabaseClient {
  static AppSupabaseClient? _instance;
  static AppSupabaseClient get instance => _instance ??= AppSupabaseClient._();

  AppSupabaseClient._();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
  }
}
