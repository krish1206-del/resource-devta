class AppUser {
  final String id;
  final String? email;
  final String fullName;
  final String role; // 'volunteer' | 'ngo_admin'
  final List<String> volunteerSkills;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.role,
    required this.volunteerSkills,
    this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: (json['full_name'] as String?)?.trim().isNotEmpty == true
          ? (json['full_name'] as String)
          : 'Unnamed',
      role: (json['role'] as String?) ?? 'volunteer',
      volunteerSkills: (json['volunteer_skills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'volunteer_skills': volunteerSkills,
    };
  }
}

