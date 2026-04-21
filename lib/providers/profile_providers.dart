import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';
import '../models/volunteer.dart';
import 'auth_provider.dart';
import 'location_provider.dart';

final volunteersStreamProvider = StreamProvider<List<Volunteer>>((ref) {
  final stream = AppSupabase.client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .order('updated_at', ascending: false);

  return stream.map((rows) => rows.map((r) => Volunteer.fromJson(r)).toList());
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileRepository {
  SupabaseClient get _db => AppSupabase.client;

  Future<void> updateSkills(List<String> skills) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    await _db.from('profiles').update({'volunteer_skills': skills}).eq('id', uid);
  }

  Future<void> setAvailability(bool available) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    await _db.from('profiles').update({'is_available': available}).eq('id', uid);
  }

  Future<void> pushLocation({required double lat, required double lng}) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    await _db.from('profiles').update({'last_lat': lat, 'last_lng': lng}).eq('id', uid);
  }
}

/// Periodically pushes user's location to `profiles` when signed in.
final locationSyncProvider = Provider<LocationSync>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  final auth = ref.watch(authProvider);
  final loc = ref.watch(locationProvider);
  final sync = LocationSync._(repo);

  if (auth.session != null) {
    final pos = loc.valueOrNull;
    if (pos != null) {
      sync._tryPush(pos.latitude, pos.longitude);
    }
  }

  ref.onDispose(sync.dispose);
  return sync;
});

class LocationSync {
  LocationSync._(this._repo);
  final ProfileRepository _repo;
  DateTime? _last;

  Future<void> _tryPush(double lat, double lng) async {
    final now = DateTime.now();
    if (_last != null && now.difference(_last!).inSeconds < 30) return;
    _last = now;
    await _repo.pushLocation(lat: lat, lng: lng);
  }

  void dispose() {}
}

