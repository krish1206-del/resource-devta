import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../core/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assignment_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/task_providers.dart';
import '../../widgets/task_card.dart';

class AdminTasksScreen extends ConsumerWidget {
  const AdminTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreate(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final t = tasks[i];
              return Column(
                children: [
                  TaskCard(task: t, distanceKm: null),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _statusChip(context, ref, t, TaskStatus.pending, 'Pending'),
                      const SizedBox(width: 8),
                      _statusChip(context, ref, t, TaskStatus.inProgress, 'In-Progress'),
                      const SizedBox(width: 8),
                      _statusChip(context, ref, t, TaskStatus.completed, 'Completed'),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _showAssign(context, ref, t.id),
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        tooltip: 'Assign volunteer',
                      ),
                      IconButton(
                        onPressed: () async {
                          await ref.read(taskRepositoryProvider).deleteTask(t.id);
                        },
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete task',
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
        error: (e, _) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _statusChip(
    BuildContext context,
    WidgetRef ref,
    Task t,
    TaskStatus status,
    String label,
  ) {
    final selected = t.status == status;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (v) async {
        if (!v) return;
        await ref.read(taskRepositoryProvider).updateStatus(t.id, status.name);
      },
    );
  }

  Future<void> _showCreate(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authProvider);
    final uid = auth.session?.user.id;
    if (uid == null) return;

    final title = TextEditingController();
    final desc = TextEditingController();
    final priority = TextEditingController(text: '50');
    final skills = TextEditingController(text: 'Logistics');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: desc,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 2,
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priority,
                  decoration: const InputDecoration(labelText: 'Priority (0-100)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skills,
                  decoration: const InputDecoration(
                    labelText: 'Required skills (comma-separated)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final reqSkills = skills.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                await ref.read(taskRepositoryProvider).create(
                      createdByNgo: uid,
                      title: title.text.trim().isEmpty ? 'Task' : title.text.trim(),
                      description: desc.text.trim(),
                      priority: int.tryParse(priority.text.trim()) ?? 0,
                      requiredSkills: reqSkills,
                    );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    title.dispose();
    desc.dispose();
    priority.dispose();
    skills.dispose();
  }

  Future<void> _showAssign(BuildContext context, WidgetRef ref, String taskId) async {
    final auth = ref.read(authProvider);
    final assignedBy = auth.session?.user.id;
    if (assignedBy == null) return;

    final volunteersAsync = await ref.read(volunteersStreamProvider.future);
    final candidates = volunteersAsync
        .where((v) => v.isAvailable)
        .toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    String? selectedVolunteerId;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign volunteer'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Volunteer'),
            items: [
              for (final v in candidates)
                DropdownMenuItem(
                  value: v.id,
                  child: Text('${v.fullName} (${v.skills.take(3).join(', ')})'),
                )
            ],
            onChanged: (v) => selectedVolunteerId = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final vid = selectedVolunteerId;
                if (vid == null) return;
                await ref.read(assignmentRepositoryProvider).assignVolunteer(
                      taskId: taskId,
                      volunteerId: vid,
                      assignedBy: assignedBy,
                    );
                try {
                  await NotificationService.notifyAssignment(
                    volunteerId: vid,
                    taskId: taskId,
                    title: 'New task assignment',
                  );
                } catch (_) {
                  // Notification is best-effort; function may be undeployed.
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }
}

