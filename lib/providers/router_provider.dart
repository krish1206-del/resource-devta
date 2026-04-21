import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_router.dart';
import 'auth_provider.dart';

final routerProvider = Provider.family<GoRouter, AuthState>((ref, auth) {
  return AppRouter.build(auth);
});

