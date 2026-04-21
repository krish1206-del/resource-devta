import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/matching_provider.dart';
import '../../widgets/task_card.dart';

class TaskMarketplaceScreen extends ConsumerWidget {
  const TaskMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchedAsync = ref.watch(matchedTasksProvider);

    return matchedAsync.when(
      data: (matched) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: const Text('Task marketplace'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'Ranked by skills, proximity, and priority.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: matched.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(child: Text('No tasks available right now.')),
                    )
                  : SliverList.separated(
                      itemCount: matched.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final mt = matched[i];
                        return TaskCard(task: mt.task, distanceKm: mt.distanceKm);
                      },
                    ),
            ),
          ],
        );
      },
      error: (e, _) => Center(child: Text(e.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

