import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import 'admin_assignments_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_tasks_screen.dart';
import 'admin_volunteers_screen.dart';

enum _AdminPage { tasks, reports, volunteers, assignments }

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  _AdminPage _page = _AdminPage.tasks;

  @override
  Widget build(BuildContext context) {
    final body = switch (_page) {
      _AdminPage.tasks => const AdminTasksScreen(),
      _AdminPage.reports => const AdminReportsScreen(),
      _AdminPage.volunteers => const AdminVolunteersScreen(),
      _AdminPage.assignments => const AdminAssignmentsScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Admin'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider).signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text('Resource-Devta'),
                subtitle: Text('Admin suite'),
                leading: Icon(Icons.shield_outlined),
              ),
              const Divider(),
              _navTile(
                label: 'Tasks',
                icon: Icons.checklist_outlined,
                selected: _page == _AdminPage.tasks,
                onTap: () => _select(_AdminPage.tasks),
              ),
              _navTile(
                label: 'Reports',
                icon: Icons.description_outlined,
                selected: _page == _AdminPage.reports,
                onTap: () => _select(_AdminPage.reports),
              ),
              _navTile(
                label: 'Volunteers',
                icon: Icons.groups_outlined,
                selected: _page == _AdminPage.volunteers,
                onTap: () => _select(_AdminPage.volunteers),
              ),
              _navTile(
                label: 'Assignments',
                icon: Icons.assignment_turned_in_outlined,
                selected: _page == _AdminPage.assignments,
                onTap: () => _select(_AdminPage.assignments),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _navTile({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      selected: selected,
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  void _select(_AdminPage p) {
    setState(() => _page = p);
    Navigator.of(context).pop();
  }
}

