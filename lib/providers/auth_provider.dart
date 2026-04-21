import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_router.dart';
import '../core/supabase_client.dart';
import '../models/app_user.dart';

final authProvider = ChangeNotifierProvider<AuthState>((ref) {
  return AuthState();
});

class AuthState extends ChangeNotifier {
  AuthState() {
    _session = AppSupabase.client.auth.currentSession;
    
    _authSub = AppSupabase.client.auth.onAuthStateChange.listen((authData) async {
      // We use 'authData' to avoid confusing the computer with '_session'
      _session = authData.session; 
      _user = null;
      _role = null;
      notifyListeners();
      
      if (_session != null) {
        await refreshProfile();
      }
    });

    if (_session != null) {
      unawaited(refreshProfile());
    }
  }


  StreamSubscription? _authSub;
  Session? _session;
  AppUser? _user;
  AppRole? _role;

  Session? get session => _session;
  AppUser? get user => _user;
  AppRole? get role => _role;

  Future<void> refreshProfile() async {
    final uid = _session?.user.id;
    if (uid == null) return;

    final row = await AppSupabase.client
        .from('profiles')
        .select('id, email, full_name, role, volunteer_skills')
        .eq('id', uid)
        .maybeSingle();

    if (row == null) {
      // First login: seed a profile row (role defaults to volunteer).
      final email = _session?.user.email;
      await AppSupabase.client.from('profiles').upsert({
        'id': uid,
        'email': email,
        'full_name': email?.split('@').first ?? 'User',
        'role': 'volunteer',
        'volunteer_skills': <String>[],
      });
      return refreshProfile();
    }

    _user = AppUser.fromJson(row);
    _role = (_user?.role == 'ngo_admin') ? AppRole.ngoAdmin : AppRole.volunteer;
    notifyListeners();
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await AppSupabase.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> registerWithPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await AppSupabase.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    final uid = res.user?.id;
    if (uid != null) {
      await AppSupabase.client.from('profiles').upsert({
        'id': uid,
        'email': email,
        'full_name': fullName,
        'role': 'volunteer',
        'volunteer_skills': <String>[],
      });
    }
  }

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
    );
    final account = await googleSignIn.signIn();
    if (account == null) return;
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw StateError('Google Sign-In failed (missing idToken).');
    }

    await AppSupabase.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: auth.accessToken,
    );
  }

  Future<void> signOut() async {
    await AppSupabase.client.auth.signOut();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

