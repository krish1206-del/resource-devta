import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final double? distanceKm;

  const TaskCard({
    super.key,
    required this.task,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final distanceText =
        distanceKm == null ? null : '${distanceKm!.toStringAsFixed(1)} km away';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _statusPill(task.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description.isEmpty ? 'No description.' : task.description),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (distanceText != null)
                  Chip(
                    label: Text(distanceText),
                    avatar: const Icon(Icons.near_me_outlined, size: 18),
                  ),
                Chip(
                  label: Text('Priority ${task.priority}'),
                  avatar: const Icon(Icons.flag_outlined, size: 18),
                  backgroundColor: cs.primaryContainer,
                ),
                for (final s in task.requiredSkills.take(4))
                  Chip(
                    label: Text(s),
                    avatar: const Icon(Icons.build_outlined, size: 18),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(TaskStatus status) {
    final (label, icon) = switch (status) {
      TaskStatus.pending => ('Pending', Icons.hourglass_empty),
      TaskStatus.inProgress => ('In-Progress', Icons.work_outline),
      TaskStatus.completed => ('Completed', Icons.check_circle_outline),
    };
    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
    );
  }
}

