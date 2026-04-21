import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/assignment_providers.dart';

class AdminAssignmentsScreen extends ConsumerWidget {
  const AdminAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(allAssignmentsStreamProvider);

    return assignmentsAsync.when(
      data: (assignments) {
        if (assignments.isEmpty) {
          return const Center(child: Text('No assignments yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: assignments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final a = assignments[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_turned_in_outlined),
                title: Text('Task ${a.taskId}'),
                subtitle: Text('Volunteer ${a.volunteerId} • ${a.status.name}'),
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

