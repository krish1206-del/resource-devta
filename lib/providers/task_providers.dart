import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';
import '../models/task.dart';

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final stream = AppSupabase.client
      .from('tasks')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

  return stream.map((rows) {
    return rows.map((r) => Task.fromJson(r)).toList();
  });
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

class TaskRepository {
  SupabaseClient get _db => AppSupabase.client;

  Future<Task> create({
    required String createdByNgo,
    required String title,
    required String description,
    required int priority,
    required List<String> requiredSkills,
    double? lat,
    double? lng,
  }) async {
    final row = await _db
        .from('tasks')
        .insert({
          'created_by_ngo': createdByNgo,
          'title': title,
          'description': description,
          'priority': priority,
          'required_skills': requiredSkills,
          'status': 'pending',
          'lat': lat,
          'lng': lng,
        })
        .select()
        .single();

    return Task.fromJson(row);
  }

  // This method calls the function below
  Future<void> updateStatus(String taskId, String status) async {
    await _db.from('tasks').update({'status': _statusToDb(status)}).eq('id', taskId);
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> patch) async {
    await _db.from('tasks').update(patch).eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _db.from('tasks').delete().eq('id', taskId);
  }

  // --- ADD THESE TWO FUNCTIONS HERE ---

  String _statusToDb(String status) {
    return status.toLowerCase().replaceAll(' ', '_');
  }

  String _statusFromDb(String status) {
    return status.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }
} // End of class