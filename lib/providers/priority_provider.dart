import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report.dart';
import 'report_providers.dart';

class PriorityIssue {
  final String label; // major problem tag
  final int count;
  final double avgSeverity;
  final double priorityScore;

  const PriorityIssue({
    required this.label,
    required this.count,
    required this.avgSeverity,
    required this.priorityScore,
  });
}

final priorityIssuesProvider = Provider<AsyncValue<List<PriorityIssue>>>((ref) {
  final reportsAsync = ref.watch(reportsStreamProvider);
  return reportsAsync.whenData(_rankIssues);
});

List<PriorityIssue> _rankIssues(List<Report> reports) {
  final byTag = <String, List<Report>>{};
  for (final r in reports) {
    final tag = (r.majorProblemTag ?? 'Uncategorized').trim();
    byTag.putIfAbsent(tag, () => []).add(r);
  }

 final issues = byTag.entries.map((e) {
    final count = e.value.length;
    final avgSeverity = e.value
            .map((r) => r.severityScore.toDouble())
            .fold<double>(0, (a, b) => a + b) /
        max(1, count);

    // Simple prioritization: frequency * severity
    final priorityScore = (count.toDouble() * avgSeverity);
    return PriorityIssue(
      label: e.key,
      count: count,
      avgSeverity: avgSeverity,
      priorityScore: priorityScore,
    );
  }).toList()
    ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

  return issues;
}

