import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase_client.dart';
import '../models/assignment.dart';
import 'auth_provider.dart';

final myAssignmentsStreamProvider = StreamProvider<List<Assignment>>((ref) {
  final auth = ref.watch(authProvider);
  final uid = auth.session?.user.id;
  if (uid == null) return const Stream.empty();

  final stream = AppSupabase.client
      .from('assignments')
      .stream(primaryKey: ['id'])
      .eq('volunteer_id', uid)
      .order('created_at', ascending: false);

  return stream.map((rows) => rows.map((r) => Assignment.fromJson(r)).toList());
});

final allAssignmentsStreamProvider = StreamProvider<List<Assignment>>((ref) {
  final stream = AppSupabase.client
      .from('assignments')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

  return stream.map((rows) => rows.map((r) => Assignment.fromJson(r)).toList());
});

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository();
});

class AssignmentRepository {
  Future<void> assignVolunteer({
    required String taskId,
    required String volunteerId,
    required String assignedBy,
  }) async {
    await AppSupabase.client.from('assignments').insert({
      'task_id': taskId,
      'volunteer_id': volunteerId,
      'assigned_by': assignedBy,
      'status': 'pending',
    });
  }

  // --- ADDED THIS METHOD ---
  Future<void> updateAssignmentStatus(String assignmentId, String status) async {
    await AppSupabase.client
        .from('assignments')
        .update({'status': _statusToDb(status)})
        .eq('id', assignmentId);
  }

  // --- ADDED THESE TWO TRANSLATOR FUNCTIONS ---
  String _statusToDb(String status) {
    return status.toLowerCase().replaceAll(' ', '_');
  }

  String _statusFromDb(String status) {
    return status.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}