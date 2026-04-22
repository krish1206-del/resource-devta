import 'package:flutter/material.dart';

import 'analytics_dashboard_screen.dart';
import 'priority_list_screen.dart';
import 'survey_architect_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      AnalyticsDashboardScreen(),
      PriorityListScreen(),
      SurveyArchitectScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.priority_high), label: 'Priority'),
          NavigationDestination(icon: Icon(Icons.note_add_outlined), label: 'New report'),
        ],
      ),
    );
  }
}

