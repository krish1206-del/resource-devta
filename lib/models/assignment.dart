import 'task.dart';

class Assignment {
  final String id;
  final String taskId;
  final String volunteerId;
  final String assignedBy;
  final TaskStatus status;
  final DateTime createdAt;

  const Assignment({
    required this.id,
    required this.taskId,
    required this.volunteerId,
    required this.assignedBy,
    required this.status,
    required this.createdAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      volunteerId: json['volunteer_id'] as String,
      assignedBy: json['assigned_by'] as String,
      status: _statusFromDb(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'volunteer_id': volunteerId,
      'assigned_by': assignedBy,
      'status': _statusToDb(status),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // --- THE MISSING TRANSLATOR FUNCTIONS ---

  static TaskStatus _statusFromDb(String? status) {
    // Looks through the TaskStatus enum and finds the one that matches the database string
    return TaskStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TaskStatus.values.first, // Safely defaults to the first status (likely 'pending') if there's a typo
    );
  }

  static String _statusToDb(TaskStatus status) {
    // Converts the enum back into a simple string for Supabase
    return status.name;
  }
}