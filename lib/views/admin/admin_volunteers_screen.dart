import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profile_providers.dart';

class AdminVolunteersScreen extends ConsumerWidget {
  const AdminVolunteersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volunteersAsync = ref.watch(volunteersStreamProvider);

    return volunteersAsync.when(
      data: (volunteers) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: volunteers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final v = volunteers[i];
            return Card(
              child: ListTile(
                leading: Icon(v.isAvailable ? Icons.circle : Icons.circle_outlined),
                title: Text(v.fullName),
                subtitle: Text(
                  '${v.skills.isEmpty ? 'No skills' : v.skills.join(', ')}'
                  '${(v.lat != null && v.lng != null) ? ' • GPS' : ''}',
                ),
                trailing: v.isAvailable
                    ? const Chip(label: Text('Available'))
                    : const Chip(label: Text('Unavailable')),
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

