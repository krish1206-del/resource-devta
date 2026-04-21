import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../providers/assignment_providers.dart';
import '../../providers/task_providers.dart';
import '../../widgets/task_card.dart';

class MyAssignmentsScreen extends ConsumerWidget {
  const MyAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(myAssignmentsStreamProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          title: Text('My tasks'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Assignments update in real time.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: assignmentsAsync.when(
            data: (assignments) {
              final tasks = tasksAsync.valueOrNull ?? const <Task>[];
              final byId = {for (final t in tasks) t.id: t};

              if (assignments.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No assignments yet.')),
                );
              }

              return SliverList.separated(
                itemCount: assignments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final a = assignments[i];
                  final t = byId[a.taskId];
                  if (t == null) {
                    return Card(
                      child: ListTile(
                        title: Text('Task ${a.taskId}'),
                        subtitle: Text('Status: ${a.status.name}'),
                      ),
                    );
                  }
                  return TaskCard(task: t, distanceKm: null);
                },
              );
            },
            error: (e, _) => SliverToBoxAdapter(child: Text(e.toString())),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }
}

