class Volunteer {
  final String id;
  final String fullName;
  final List<String> skills;
  final bool isAvailable;
  final double? lat;
  final double? lng;

  const Volunteer({
    required this.id,
    required this.fullName,
    required this.skills,
    required this.isAvailable,
    this.lat,
    this.lng,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? 'Volunteer',
      skills: (json['volunteer_skills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isAvailable: (json['is_available'] as bool?) ?? false,
      lat: (json['last_lat'] as num?)?.toDouble() ?? (json['lat'] as num?)?.toDouble(),
      lng: (json['last_lng'] as num?)?.toDouble() ?? (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'volunteer_skills': skills,
      'is_available': isAvailable,
      'last_lat': lat,
      'last_lng': lng,
    };
  }
}

