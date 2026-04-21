import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'core/supabase_client.dart';
import 'providers/auth_provider.dart';
import 'providers/router_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await AppSupabase.initialize();
  runApp(const ProviderScope(child: ResourceDevtaApp()));
}

class ResourceDevtaApp extends ConsumerWidget {
  const ResourceDevtaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final router = ref.watch(routerProvider(auth));

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      title: 'Resource-Devta',
    );
  }
}

