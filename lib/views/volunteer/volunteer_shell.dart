import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profile_providers.dart';
import 'my_assignments_screen.dart';
import 'task_marketplace_screen.dart';
import 'volunteer_profile_screen.dart';

class VolunteerShell extends ConsumerStatefulWidget {
  const VolunteerShell({super.key});

  @override
  ConsumerState<VolunteerShell> createState() => _VolunteerShellState();
}

class _VolunteerShellState extends ConsumerState<VolunteerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Ensure location sync runs while on volunteer shell.
    ref.watch(locationSyncProvider);

    final pages = const [
      TaskMarketplaceScreen(),
      MyAssignmentsScreen(),
      VolunteerProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            label: 'Marketplace',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'My Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

