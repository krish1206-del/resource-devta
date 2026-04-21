import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase_client.dart';
import '../models/report.dart';

final reportsStreamProvider = StreamProvider<List<Report>>((ref) {
  final stream = AppSupabase.client
      .from('reports')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

  return stream.map((rows) => rows.map((r) => Report.fromJson(r)).toList());
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

class ReportsRepository {
  Future<void> create({
    required String createdBy,
    required String title,
    required Map<String, dynamic> payload,
    required int severityScore,
    String? majorProblemTag,
    double? lat,
    double? lng,
  }) async {
    await AppSupabase.client.from('reports').insert({
      'created_by': createdBy,
      'title': title,
      'payload': payload,
      'severity_score': severityScore,
      'major_problem_tag': majorProblemTag,
      'lat': lat,
      'lng': lng,
    });
  }
}

