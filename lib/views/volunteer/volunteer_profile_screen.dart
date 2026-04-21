import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/volunteer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_providers.dart';

class VolunteerProfileScreen extends ConsumerStatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  ConsumerState<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends ConsumerState<VolunteerProfileScreen> {
  final _skill = TextEditingController();

  @override
  void dispose() {
    _skill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final repo = ref.read(profileRepositoryProvider);
    final uid = auth.session?.user.id;
    final volunteers =
        ref.watch(volunteersStreamProvider).valueOrNull ?? const <Volunteer>[];
    Volunteer? me;
    if (uid != null) {
      for (final v in volunteers) {
        if (v.id == uid) {
          me = v;
          break;
        }
      }
    }
    final skills = user?.volunteerSkills ?? const <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider).signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(user?.fullName ?? 'Loading...'),
              subtitle: Text(user?.email ?? ''),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Availability'),
              subtitle: const Text('Used for NGO dispatch + realtime matching'),
              trailing: Switch(
                value: me?.isAvailable ?? false,
                onChanged: (v) async {
                  await repo.setAvailability(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Skills', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in skills)
                InputChip(
                  label: Text(s),
                  onDeleted: () async {
                    final next = skills.where((x) => x != s).toList();
                    await repo.updateSkills(next);
                    await ref.read(authProvider).refreshProfile();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skill,
                  decoration: const InputDecoration(
                    labelText: 'Add skill',
                    hintText: 'e.g., First Aid, Logistics',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () async {
                  final s = _skill.text.trim();
                  if (s.isEmpty) return;
                  final next = [...skills, s];
                  await repo.updateSkills(next);
                  await ref.read(authProvider).refreshProfile();
                  _skill.clear();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

