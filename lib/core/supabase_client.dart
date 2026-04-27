import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      // Allow the app to run as a UI prototype without backend credentials.
      // Any features that require Supabase will fail later with clearer errors.
      _initialized = false;
      return;
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
    );
    _initialized = true;
  }
}

