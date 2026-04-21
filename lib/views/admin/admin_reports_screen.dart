import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/report_providers.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsStreamProvider);

    return reportsAsync.when(
      data: (reports) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final r = reports[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(r.title),
                subtitle: Text(
                  '${r.majorProblemTag ?? 'Uncategorized'} • severity ${r.severityScore}'
                  '${(r.lat != null && r.lng != null) ? ' • GPS tagged' : ''}',
                ),
              ),
            );
          },
        );
      },
      error: (e, _) => Center(child: Text(e.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

