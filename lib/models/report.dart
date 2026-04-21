class Report {
  final String id;
  final String createdBy;
  final DateTime createdAt;

  // Survey architect output
  final String title;
  final Map<String, dynamic> payload;

  // Severity + geo tag
  final int severityScore; // 1..10
  final double? lat;
  final double? lng;
  final String? majorProblemTag;

  const Report({
    required this.id,
    required this.createdBy,
    required this.createdAt,
    required this.title,
    required this.payload,
    required this.severityScore,
    this.lat,
    this.lng,
    this.majorProblemTag,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      title: (json['title'] as String?) ?? 'Report',
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
      severityScore: (json['severity_score'] as int?) ?? 1,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      majorProblemTag: json['major_problem_tag'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'payload': payload,
      'severity_score': severityScore,
      'major_problem_tag': majorProblemTag,
      'lat': lat,
      'lng': lng,
    };
  }
}

