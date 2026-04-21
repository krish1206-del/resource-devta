import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/priority_provider.dart';
import '../../widgets/priority_badge.dart';

class PriorityListScreen extends ConsumerWidget {
  const PriorityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(priorityIssuesProvider);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          title: Text('Priority ranking'),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: issuesAsync.when(
            data: (issues) {
              if (issues.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No reports yet. Create one to start.')),
                );
              }
              return SliverList.separated(
                itemCount: issues.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final it = issues[i];
                  return Card(
                    child: ListTile(
                      title: Text(it.label),
                      subtitle: Text(
                        'Reports: ${it.count} • Avg severity: ${it.avgSeverity.toStringAsFixed(1)}',
                      ),
                      trailing: PriorityBadge(score: it.priorityScore),
                    ),
                  );
                },
              );
            },
            error: (e, _) => SliverToBoxAdapter(child: Text(e.toString())),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

