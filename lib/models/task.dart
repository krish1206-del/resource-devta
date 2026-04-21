enum TaskStatus { pending, inProgress, completed }

class Task {
  final String id;
  final DateTime createdAt;
  final String createdByNgo; // profile id

  final String title;
  final String description;
  final int priority; // higher = more urgent
  final List<String> requiredSkills;

  final TaskStatus status;
  final double? lat;
  final double? lng;

  const Task({
    required this.id,
    required this.createdAt,
    required this.createdByNgo,
    required this.title,
    required this.description,
    required this.priority,
    required this.requiredSkills,
    required this.status,
    this.lat,
    this.lng,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdByNgo: json['created_by_ngo'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      priority: (json['priority'] as int?) ?? 0,
      requiredSkills: (json['required_skills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: _statusFromDb(json['status'] as String?),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'created_by_ngo': createdByNgo,
      'title': title,
      'description': description,
      'priority': priority,
      'required_skills': requiredSkills,
      'status': _statusToDb(status),
      'lat': lat,
      'lng': lng,
    };
  }
}

TaskStatus _statusFromDb(String? s) {
  switch (s) {
    case 'in_progress':
      return TaskStatus.inProgress;
    case 'completed':
      return TaskStatus.completed;
    case 'pending':
    default:
      return TaskStatus.pending;
  }
}

String _statusToDb(TaskStatus s) {
  switch (s) {
    case TaskStatus.inProgress:
      return 'in_progress';
    case TaskStatus.completed:
      return 'completed';
    case TaskStatus.pending:
      return 'pending';
  }
}

