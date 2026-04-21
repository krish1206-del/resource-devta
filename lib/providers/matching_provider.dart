import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/task.dart';
import 'auth_provider.dart';
import 'location_provider.dart';
import 'task_providers.dart';

class MatchedTask {
  final Task task;
  final double? distanceKm;
  final double score;

  const MatchedTask({
    required this.task,
    required this.distanceKm,
    required this.score,
  });
}

final matchedTasksProvider = Provider<AsyncValue<List<MatchedTask>>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final locAsync = ref.watch(locationProvider);
  final auth = ref.watch(authProvider);

  return tasksAsync.whenData((tasks) {
    final skills = auth.user?.volunteerSkills ?? const <String>[];
    final pos = locAsync.valueOrNull;

    final matched = tasks
        .where((t) => t.status == TaskStatus.pending || t.status == TaskStatus.inProgress)
        .map((t) {
          final distanceKm = _distanceKm(pos, t.lat, t.lng);
          final skillsScore = _skillsScore(skills, t.requiredSkills);
          final proximityScore = distanceKm == null ? 0.25 : 1 / (1 + distanceKm);
          final priorityScore = (t.priority.clamp(0, 100)) / 100.0;

          // Weighted score: tune as needed.
          final score = (0.45 * skillsScore) +
              (0.35 * proximityScore) +
              (0.20 * priorityScore);

          return MatchedTask(task: t, distanceKm: distanceKm, score: score);
        })
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return matched;
  });
});

double? _distanceKm(Position? pos, double? lat, double? lng) {
  if (pos == null || lat == null || lng == null) return null;
  final meters = Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, lng);
  return meters / 1000.0;
}

double _skillsScore(List<String> volunteerSkills, List<String> requiredSkills) {
  if (requiredSkills.isEmpty) return 0.7;
  if (volunteerSkills.isEmpty) return 0.0;
  final v = volunteerSkills.map((e) => e.toLowerCase().trim()).toSet();
  final r = requiredSkills.map((e) => e.toLowerCase().trim()).toSet();
  final overlap = v.intersection(r).length;
  return min(1.0, overlap / max(1, r.length));
}

